#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import hardposit as hp
import fixed2float as fi
from pathlib import Path
import re


# In[20]:


import fixed2float
fixed2float.__version__


# In[21]:


N, ES = 16, 1
M, B = 31, 64


# In[22]:


with open(Path("../tb_core_op_fma.log"), 'r') as f:
  log = f.read()
print(log)


# In[23]:


logs = log.splitlines()
print(logs)


# In[24]:


pattern = r"0x[0-9a-z]+"

diff_fma = [0] * len(logs)
diff_normal_mul = [0] * len(logs)

acc = 0
for (i, item) in enumerate(logs):
  results = re.findall(pattern, item)
  if len(results) == 1:
    p3 = hp.from_bits(int(results[0], 16), N, ES)
    po_std_mul = p3
    acc += p3.eval()
  else:
    p1 = hp.from_bits(int(results[0], 16), N, ES)
    p2 = hp.from_bits(int(results[1], 16), N, ES)
    print(p1.eval(), p2.eval(), (p1*p2).eval())

    fixed = fi.from_bits(int(results[2], 16), M, B)
    print(f"fixed={fixed}")
    
    po_fma = hp.from_bits(int(results[3], 16), N, ES)
    po_std_mul += p1 * p2 
    print(f"po_fma     = {po_fma}")
    print(f"po_std_mul = {po_std_mul}")
    
    acc += p1.eval() * p2.eval()
    print(f"acc={acc}")
    
    diff_normal_mul[i] = abs(po_std_mul.eval() - acc)
    diff_fma[i] = abs(po_fma.eval() - acc)
    
    print()
    assert acc == fixed.eval(), f"acc = {acc}, fixed = {fixed.eval()}"


# In[32]:


hp.from_double(acc, N, ES)
