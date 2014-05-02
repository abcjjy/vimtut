//HGEN generated header files
#ifndef __HGENSAMPLE_H__
#define __HGENSAMPLE_H__

#include <string>
using namespace std;

class XX {

public:
    virtual void bark() = 0;
};

/*
block comment
*/
class Foo : public XX {
private:
    void privateFunc (int a, char * b);
protected:
    /* This is a void proected virtual function */
    virtual void protectedFunc (string &x);
public:
    /*
    * Document goes here.
    */
    Foo ();
    Foo (int m, string& z);
    virtual  ~Foo ();
    static Foo* create ();
    virtual void bark ();
private:
    std::string m_sMember;
protected:
    float m_fMember;
public:
    int m_iMember;
    long m_lMember;
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

class YYY : public XX
{
public:
    /* here is a comment
    * MULTILINE
    */
    virtual void foo ();
private:
    int m_isafa;
    std::vector<int> m_aVec;
protected:
    std::map<int, int> m_omap;
public:
    int m_iMember; // variable comment
    float m_fFm;
    static int adfa;
};


int add (int a, int b);

#endif
