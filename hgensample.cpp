/*H_Delare
#include <string>
using namespace std;

class XX {
//H_MethodDeclare XX
public:
    virtual void bark() = 0;
};

/#
block comment
#/
class Foo : public XX {
//H_MethodDeclare Foo
private:
    int field;
    string sf;
public:
    static int pubf;
};

template <class T> class tplcls {
//H_MethodDeclare tplcls
private:
    T a;
};
//H_FunctionDelare
*/
#include <string>
#include "mergedcpp.h"

using namespace std;

int Foo::pubf = 1;

/*
 * Document goes here.
 */
//H_Method public
Foo::Foo():field(0) {
}
//H_Method public
Foo::Foo(int m, string& z) {
}

//H_Method public virtual
Foo::~Foo() {
}

//H_Method public static
Foo* Foo::create() {
}

//H_Method public virtual
void Foo::bark() {
}

//H_Method private
void Foo::privateFunc(int a, char * b) {
}

/* This is a void proected virtual function */
//H_Method protected virtual
void Foo::protectedFunc(string &x) {
}

/*
 * This is the getter.
 */
//H_Method public
template<class T> T tplcls<T>::getA() {
};

//H_Function
template <class myType> myType GetMax (myType a, myType b) {
 return (a>b?a:b);
}

/*
 * C function is also copy and declared
 */
//H_Function
int add(int a, int b) {
}

int main() {
    Foo f;
    f.bark();
    tplcls<int> t;
    t.getA();
    return 0;
}
