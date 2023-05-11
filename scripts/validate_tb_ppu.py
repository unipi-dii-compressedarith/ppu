#!/usr/bin/env python
# coding: utf-8

# In[126]:


import os
import hardposit as hp
import softposit as sp
import fixed2float as fi
from pathlib import Path
import re
import ast


# In[127]:


import fixed2float
fixed2float.__version__


# In[128]:


N, ES = 16, 1


# In[172]:


with open(Path("../tb_ppu.log"), 'r') as f:
  log = f.read()
print(log)


# In[173]:


log.splitlines()


# In[174]:


log.splitlines()[0]


# In[175]:


lst = list(map(lambda l: ast.literal_eval(l), log.splitlines()))


# In[176]:


operand1_i, operand2_i, fixed_o, result_o = list(zip(*lst)) 


# In[177]:


operand1_i, operand2_i, fixed_o, result_o


# In[178]:


acc = hp.from_bits(0, N, ES)
for (operand1, operand2) in zip(operand1_i, operand2_i):
  acc += (hp.from_bits(operand1, N, ES) * hp.from_bits(operand2, N, ES))


# In[179]:


acc


# In[180]:


M, B = 31, 64
fi.from_bits(fixed_o[-1], M, B)


# In[181]:


hp.from_bits(result_o[-1], N, ES).eval()


# ### test result using softposit

# In[182]:


softposit_acc = [0] * len(operand1_i)

q = sp.quire16()

for i, (operand1, operand2) in enumerate(zip(operand1_i, operand2_i)):
  q.qma(
    sp.posit16(bits=operand1), sp.posit16(bits=operand2)
  )
  softposit_acc[i] = q.v


# In[183]:


softposit_acc


# ### FPPU hardware outputs

# In[184]:


results_o = list(map(lambda bits: hp.from_bits(bits, N, ES).eval(), result_o))
results_o


# In[185]:


matches = list(map(lambda val1, val2: val1 == val2, map(str, results_o), map(str, softposit_acc)))


# In[186]:


assert all(matches) == True
print("Congratulation, it works.")
