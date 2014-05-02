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
//H_MVarDeclare Foo
private:
    int field;
    string sf;
public:
    static int pubf;
};

template <class T> class tplcls {
private:
    T a;
};

//H_Class YYY : public XX

//H_FunctionDelare
*/
#include <string>
#include "mergedcpp.h"

using namespace std;

/* here is a comment
 * MULTILINE
*/
//H_Method public virtual
void YYY::foo()
{
    //H_MVar public int
    m_iMember = 0; // variable comment
    //H_MVar public float
    m_fFmv;
    //H_MVar private int
    m_isafa= 0;
    //H_MVar protected std::map<int, int>
    m_omap.clear();
    //H_MVar private std::vector<int>
    m_aVec = {};
    //H_MVar private int
    m_ilakfla=1;
}

//H_MVar public static
int YYY::adfa = 1;

int Foo::pubf = 1;


/*
 * Document goes here.
 */
//H_Method public
Foo::Foo():field(0) {
}
//H_Method public
Foo::Foo(int m, string& z) {
    //H_MVar public int
    m_iMember = 0;
    //H_MVar private std::string
    m_sMember = "asdf";
    //H_MVar protected float
    m_fMember = 0.1;
    //H_MVar public long
    m_lMember = 1L;
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
