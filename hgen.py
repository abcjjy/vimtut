#!/usr/bin/python

import re
import sys
import os.path
from collections import defaultdict
import StringIO

def findDeclareTemplate(src):
    startRe = re.compile(r'/\*\s*H_Declare')
    endRe = re.compile(r'\*/')
    start = startRe.search(src)
    end = endRe.search(src, start.end())
    template = src[start.end():end.start()]
    return template.replace('/#', '/*').replace('#/', '*/')

def findMethodDefs(src):
    methodRe = re.compile(r'//\s*H_Method\b')
    defRe = re.compile(r'(?:template\s*<\s*class\s+\w+\s*>\s+)?(\w+(?:\w+\s+)*\s*[\w\*&<>]*\s+)?(?:[\w:]+::)?(\w+)(?:<\w+>)?\s*::\s*([^:()\s]+\s*\([^()]*\))')
    pos = 0
    def factory():
        return defaultdict(list)
    methods = defaultdict(factory)
    access = 'public protected private'.split(' ')
    while True:
        m = methodRe.search(src, pos)
        if not m:
            break
        pos = m.end()
        comment = lookbackComment(src, m.start())
        nl = src.index('\n', pos)
        astr = src[pos:nl].strip()
        attrs = astr.split()
        accessModifiers = [x.strip() for x in attrs if x.strip() in access]
        if accessModifiers:
            accessModifier = accessModifiers[0]
            attrs.remove(accessModifier)
        else:
            accessModifier = 'private'
        clsm = defRe.search(src, nl)
        if not clsm:
            print 'Failed to find method def starting from %d'%pos
            continue
        cls = clsm.group(2)
        rettype = clsm.group(1).strip() if clsm.group(1) else ''
        method = clsm.group(3).strip()
        mlist = list(attrs)
        if rettype:
            mlist.append(rettype)
        mlist.append(method)
        methods[cls][accessModifier].append({'def': ' '.join(mlist), 'comment': comment})
    return methods

def lookbackComment(src, pos):
    cclose = src.rfind('*/', 0, pos)+2
    copen = src.rfind('/*', 0, pos)
    if copen < 0 or cclose < 0:
        return None
    interval = src[cclose:pos]
    if interval.strip() == '':
        return src[copen:cclose]
    else:
        return None

def findFuncDefs(src):
    funcRe = re.compile(r'//\s*H_Function\b')
    defRe = re.compile(r'(?:template\s*<\s*class\s+\w+\s*>\s+)?(\w+(?:\w+\s+)*\s*[\w\*&<>]*\s+)(?:[\w:]+::)?([^:()\s]+\s*\([^()]*\))')
    pos = 0
    funcs = []
    for mark in funcRe.finditer(src):
        m = defRe.search(src, mark.end())
        if not m:
            print 'Not found function at %d'%mark.end()
            continue
        funcs.append(m.group().strip() + ";")
    return funcs

def findVarDefs(src):
    varRe = re.compile(r'//\s*H_Variable\b')
    defRe = re.compile(r'\s*([^()=]+)')
    varis = []
    for mark in varRe.finditer(src):
        m = defRe.match(src, mark.end())
        if not m:
            print 'Not found variables def at %d'%mark.end()
            continue
        varis.append("extern " + m.group(1).strip() + ";")
    return varis;

def fillTemplate(src, methods, functions, variables):
    methodHolderRe = re.compile(r'//\s*H_MethodDeclare\s+(\w+)')
    funcHolderRe = re.compile(r'//\s*H_FunctionDec?lare')
    varHoldersRe = re.compile(r'//\s*H_VariableDeclare')
    dest = StringIO.StringIO()
    lastPos = 0
    for i, m in enumerate(methodHolderRe.finditer(src)):
        dest.write(src[lastPos:m.start()])
        lastPos = m.end()
        for access in 'public protected private'.split():
            if access not in methods[m.group(1)]:
                continue
            ms = methods[m.group(1)][access]
            dest.write(access)
            dest.write(':\n')
            for mdecl in ms:
                dest.write('    ')
                if mdecl['comment']:
                    dest.write(mdecl['comment'].replace('\n', '\n    '))
                    dest.write('\n    ')
                dest.write(mdecl['def'])
                dest.write(';\n')
    dest.write(src[lastPos:])
    src = dest.getvalue()
    src = funcHolderRe.sub('\n'.join(functions), src)
    return varHoldersRe.sub('\n'.join(variables), src) 

def addMacros(h, fn):
    fn = os.path.basename(fn)
    macro = '__'+fn.replace('.', '_').upper()+'__'
    header = '//HGEN generated header files\n'
    header += '#ifndef %s\n#define %s\n'%(macro, macro)
    return header + h + '\n#endif\n'

def process(src, fn):
    decls = findDeclareTemplate(src)
    methods = findMethodDefs(src)
    functions = findFuncDefs(src)
    variables = findVarDefs(src)
    h = fillTemplate(decls, methods, functions, variables)
    #print h
    return addMacros(h, fn)

def main():
    args = sys.argv[1:]
    for f in args:
        bname, ext = os.path.splitext(f)
        outf = bname + '.h'
        if os.path.exists(outf):
            with open(outf) as fp:
                content = fp.read(100)
            if not content.startswith('//HGEN'):
                print '%s is not managed by HGEN, skip it'%outf
                continue
        with open(f) as fp:
            src = fp.read()
        h = process(src, outf)
        with open(outf, 'w') as fp:
            fp.write(h)
        print 'write to ', outf

if __name__ == '__main__':
    main()
