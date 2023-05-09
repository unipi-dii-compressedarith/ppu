#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import hardposit as hp
import fixed2float as fi
from pathlib import Path
import re
import ast


# In[2]:


import fixed2float
fixed2float.__version__


# In[3]:


N, ES = 16, 1


# In[4]:


with open(Path("../tb_core_op_fma.log"), 'r') as f:
  log = f.read()
print(log)


# In[5]:


logs = log.splitlines()
# print(logs)


# In[6]:


logs[0]


# In[7]:


# Fixed point params : Fx<M, B> := 1 sign bit, M int bits, B total bits    (B-M-1 fractional bits)
M, B = ast.literal_eval(logs[0])
M, B


# In[8]:


pattern = r"0x[0-9a-z]+"

diff_fma = [0] * len(logs)
diff_normal_mul = [0] * len(logs)

acc = 0
for (i, item) in enumerate(logs[1:]):
  results = re.findall(pattern, item)
  if len(results) == 1:
    p3 = hp.from_bits(int(results[0], 16), N, ES)
    po_std_mul = p3
    acc += p3.eval()
  else:
    p1 = hp.from_bits(int(results[0], 16), N, ES)
    p2 = hp.from_bits(int(results[1], 16), N, ES)
    print(f"i = {i}")
    print(f"{p1.eval()} * {p2.eval()} = {(p1*p2).eval()}")

    fixed = fi.from_bits(int(results[2], 16), M, B)
    print(f"fixed={fixed}")
    
    po_fma = hp.from_bits(int(results[3], 16), N, ES)
    po_std_mul += p1 * p2 
    print(f"po_fma     = {po_fma}")
    print(f"po_std_mul = {po_std_mul}")
    
    acc += p1.eval() * p2.eval()
    print(f"acc={acc}\n")
    
    diff_normal_mul[i] = 100*abs((po_std_mul.eval() - acc) / acc)
    diff_fma[i] = 100*abs((po_fma.eval() - acc) / acc)
    
    assert acc == fixed.eval(), f"iter = {i} => acc = {acc}, fixed = {fixed.eval()}"
