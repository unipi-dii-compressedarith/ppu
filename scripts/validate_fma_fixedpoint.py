#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import hardposit as hp
import fixed2float as fi
from pathlib import Path
import re


# In[2]:


get_ipython().system('date')


# In[3]:


import fixed2float
fixed2float.__version__


# In[4]:


N, ES = 16, 1
M, B = 31, 64


# In[5]:


with open(Path("../tb_core_op_fma.log"), 'r') as f:
  log = f.read()
print(log)


# In[6]:


logs = log.splitlines()
print(logs)


# In[7]:


pattern = r"0x[0-9a-z]+"

acc = 0
for item in logs:
  results = re.findall(pattern, item)
  if len(results) == 1:
    p3 = hp.from_bits(int(results[0], 16), N, ES)
    acc += p3.eval()
  else:
    p1 = hp.from_bits(int(results[0], 16), N, ES)
    p2 = hp.from_bits(int(results[1], 16), N, ES)
    print(p1.eval(), p2.eval(), (p1*p2).eval())

    fixed = fi.from_bits(int(results[2], 16), M, B)
    print(f"fixed={fixed}")
    acc += p1.eval() * p2.eval()
    print(f"acc={acc}")
    print()

    assert acc == fixed.eval()

