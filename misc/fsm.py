"""
model of fsm that manages the pipeline

note: double-underscored identifiers get mangled, hence not exported.
i.e. fsm states are internal to the class itself.

pattern matching requires Python3.10+
"""


class Fsm:
    __None = 0
    __Add0 = 1
    __Add1 = 2
    __Mul0 = 3
    __Mul1 = 4
    __Div0 = 5
    __Div1 = 6
    __Div2 = 7

    def __init__(self):
        self.state = self.__None

    @property
    def valid_o(self):
        match self.state:
            case self.__Div2 | self.__Add1 | self.__Mul1:
                return 1
            case _:
                return 0

    @property
    def statestr(self):
        match self.state:
            case self.__None:
                return "None"
            case self.__Add0:
                return "Add1"
            case self.__Add1:
                return "Add2"
            case self.__Mul0:
                return "Mul1"
            case self.__Mul1:
                return "Mul2"
            case self.__Div0:
                return "Div1"
            case self.__Div1:
                return "Div2"
            case self.__Div2:
                return "Div3"

    def __run(self, en=None, op=None):
        while True:
            match en:
                case 0:
                    pass
                case _:
                    match op:
                        case "+":
                            match self.state:
                                case self.__Add0:
                                    self.state = self.__Add1
                                case self.__Mul0:
                                    self.state = self.__Mul1
                                case self.__Div0:
                                    self.state = self.__Div1
                                case self.__Div1:
                                    self.state = self.__Div2
                                case _:
                                    self.state = self.__Add0
                        case "*":
                            match self.state:
                                case self.__Add0:
                                    self.state = self.__Add1
                                case self.__Mul0:
                                    self.state = self.__Mul1
                                case self.__Div0:
                                    self.state = self.__Div1
                                case self.__Div1:
                                    self.state = self.__Div2
                                case _:
                                    self.state = self.__Mul0
                        case "/":
                            match self.state:
                                case self.__Add0:
                                    self.state = self.__Add1
                                case self.__Mul0:
                                    self.state = self.__Mul1
                                case self.__Div0:
                                    self.state = self.__Div1
                                case self.__Div1:
                                    self.state = self.__Div2
                                case _:
                                    self.state = self.__Div0
                        case _:
                            match self.state:
                                case self.__Add0:
                                    self.state = self.__Add1
                                case self.__Mul0:
                                    self.state = self.__Mul1
                                case self.__Div0:
                                    self.state = self.__Div1
                                case self.__Div1:
                                    self.state = self.__Div2
                                case _:
                                    self.state = self.__None

            print(self.statestr)
            print(self.valid_o)
            yield self.state

    def next(self, op=None, en=1):
        self.__run(en, op).__next__()


f = Fsm()
assert f.statestr == "None"
f.next()
assert f.statestr == "None"
assert f.valid_o == 0
f.next("+")
assert f.statestr == "Add1"
assert f.valid_o == 0
f.next()
f.next("/")
assert f.statestr == "Div1"
assert f.valid_o == 0
f.next("*")
assert f.statestr == "Div2"
assert f.valid_o == 0
f.next("*")
assert f.statestr == "Div3"
assert f.valid_o == 1
