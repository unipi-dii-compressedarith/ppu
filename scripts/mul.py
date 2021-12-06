from posit_decode import Posit

def mul(p1: Posit, p2: Posit) -> Posit:
    assert p1.size == p2.size
    assert p1.es == p2.es

    if p1.is_zero or p2.is_zero:
        return Posit(is_zero=True)
    if p1.is_inf or p2.is_inf:
        return Posit(is_inf=True)
    
    if p1.es == 0:
        a = 2
    else:
        raise NotImplemented
