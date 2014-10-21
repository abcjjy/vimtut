#!/usr/bin/python
#coding:utf-8

import re
import sys
import os.path
from collections import defaultdict
import StringIO
import argparse
import string
import logging
import itertools

class CodeFile(object):
    def __init__(self, source):
        self.source = source

    def genHeader(self, headername):
        decls = DeclareTemplate(self.source)
        clzs = ClassDef.from_src(self.source)
        functions = FunctionDef.from_src(self.source)
        h = decls.genHeader(clzs, functions, None)
        return self.addMacros(h, headername)

    def addMacros(self, headerContent, headername):
        fn = os.path.basename(headername)
        macro = '__'+fn.replace('.', '_').upper()+'__'
        header = '//HGEN generated header files\n'
        header += '#ifndef %s\n#define %s\n'%(macro, macro)
        return header + headerContent + '\n#endif\n'

    def findClasses(self):
        pass

class DeclareTemplate(object):
    classHolderRe = re.compile(r'//\s*H_Class\s+(.+)$', re.MULTILINE)
    methodHolderRe = re.compile(r'//\s*H_MethodDeclare\s+(\w+)\s*$', re.MULTILINE)
    mvarHolderRe = re.compile(r'//\s*H_MVarDeclare\s+(\w+)\s*$', re.MULTILINE)
    funcHolderRe = re.compile(r'//\s*H_FunctionDec?lare', re.MULTILINE)
    varHoldersRe = re.compile(r'//\s*H_VariableDeclare', re.MULTILINE)

    def __init__(self, src):
        startRe = re.compile(r'/\*\s*H_Dec?lare')
        endRe = re.compile(r'\*/')
        start = startRe.search(src)
        end = endRe.search(src, start.end())
        template = src[start.end():end.start()]
        self.header_template = template.replace('/#', '/*').replace('#/', '*/')
        
    def genHeader(self, clzs, functions, variables):
        #fill class template for H_Class
        header = DeclareTemplate.classHolderRe.sub(lambda x: makeClassTemplate(x.group(1)), self.header_template)
        #fill class methods
        header = DeclareTemplate.methodHolderRe.sub(lambda m : clzs[m.group(1)].getMethodDecl() if m.group(1) in clzs else '', header)
        #fill class member var
        header = DeclareTemplate.mvarHolderRe.sub(lambda m : clzs[m.group(1)].getMVarDecl() if m.group(1) in clzs else '', header)
        #fill functions
        header = DeclareTemplate.funcHolderRe.sub(lambda m : '\n'.join(map(lambda f: f.getDecl(), functions)), header)
        return header

class MemberMethod(object):
    tagRe = re.compile(r'//\s*H_Method\s+(?P<access>\w+)(?:\s+(?P<prefix_modifier>[\w\s]+))?\s*$', re.MULTILINE)
    methodRe = re.compile(r'(?P<return_type>\w[\s\w\*&<>,:]*\s+)?(?:[\w:]+::)?(?P<clz>\w+)\s*::\s*(?P<name>[^:()\s]+)\s*(?P<args>\([^{\n]*\))\s*(?P<suffix_modifier>[\w\s]+)?', re.MULTILINE)
    def __init__(self, name=None, clz=None, access=None, prefix_modifier=None, return_type=None, args=None, suffix_modifier=None):
        self.name = name
        self.clz = clz
        self.access = access
        self.prefix_modifier = prefix_modifier
        self.suffix_modifier = suffix_modifier
        self.return_type = return_type
        self.args = args
        self.comment = None

    def __str__(self):
        return str(vars(self))

    def getDecl(self):
        code = ('%s %s %s %s %s'%(self.prefix_modifier, self.return_type, self.name, self.args, self.suffix_modifier)).strip() + ';'
        if self.comment:
            return '\n'.join([self.comment, code])
        else:
            return code

    @staticmethod
    def from_src(src):
        methods = []
        logging.debug('MemberMethod.from_src')
        for tagm in MemberMethod.tagRe.finditer(src):
            logging.debug('find tagm')
            method = MemberMethod(access=xstr(tagm.group('access')), prefix_modifier=xstr(tagm.group('prefix_modifier')).strip())
            method.comment = xstr(lookbackComment(src, tagm.start()))
            mdecl = MemberMethod.methodRe.search(src, tagm.end(), tagm.end()+500)
            if mdecl:
                method.name = xstr(mdecl.group('name'))
                method.clz = xstr(mdecl.group('clz'))
                method.return_type = xstr(mdecl.group('return_type'))
                method.suffix_modifier = xstr(mdecl.group('suffix_modifier'))
                method.args = xstr(mdecl.group('args')).replace('/*','').replace('*/', '')
                methods.append(method)
                logging.debug("method: %s",str(method))
        return methods

def xstr(o):
    if o == None:
        return ''
    else:
        return o.strip()
            
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

class MemberVar(object):
    tag_re = re.compile(r'//\s*H_MVar\s+(?P<access>\w+)\b(?P<dtype>.+)?$', re.MULTILINE)
    mvar_re = re.compile(r'(?:(?P<dtype>(?:const\s+)?[\w\*\d<>:,]+)\s+(?P<clz>\w+)\s*::\s*)?(?P<name>[\w\d]+)[^\n;]*;?[^\n/]*(?P<comment>//[^\n]+)?$', re.MULTILINE)
    #mvar_re = re.compile(r'(?:(?P<clz>\w+)\s*::\s*)?(?P<name>[\w\d]+)', re.MULTILINE)
    def __init__(self, name=None, clz=None, access=None, dtype=None):
        self.name = name
        self.clz = clz
        self.access = access
        self.dtype = dtype
        self.comment = None

    def __str__(self):
        return str(vars(self))

    def getDecl(self):
        code = '%s %s;'%(self.dtype, self.name)
        if self.comment:
            return ' '.join([code, self.comment])
        return code

    @staticmethod
    def from_src(src):
        mvars = []
        for tagm in MemberVar.tag_re.finditer(src):
            mvar = MemberVar(dtype=xstr(tagm.group('dtype')), access=xstr(tagm.group('access')).strip())
            mvar.clz = lookback4clz(src, tagm.start())
            logging.debug(tagm.group(0))
            logging.debug(src[tagm.end():tagm.end()+100])
            mvardecl = MemberVar.mvar_re.search(src, tagm.end(), tagm.end()+200)
            if mvardecl:
                mvar.name = xstr(mvardecl.group('name'))
                if mvardecl.group('clz'):
                    mvar.clz = mvardecl.group('clz')
                    mvar.dtype += ' ' + mvardecl.group('dtype').strip()
                mvar.comment = xstr(mvardecl.group('comment'))
                logging.debug(mvar)
                mvars.append(mvar)
        return mvars

def lookback4clz(src, pos):
    while True:
        start = src.rfind('H_Method ', 0, pos)
        if start < 0:
            return None
        start = src.rfind('//', 0, start)
        if start < 0:
            return None
        tagm = MemberMethod.tagRe.match(src, start)
        if not tagm:
            continue
        mm = MemberMethod.methodRe.search(src, tagm.end())
        if not mm:
            continue
        return mm.group('clz')
    

class ClassDef(object):
    def __init__(self):
        self.name = None
        self.methods = []
        self.variables = []

    def getMethodDecl(self):
        lines = []
        self.methods.sort(lambda x, y: cmp(x.access, y.access))
        for access, g in itertools.groupby(self.methods, lambda m : m.access):
            lines.append('%s:'%access)
            for m in g:
                lines += map(lambda x: '    '+x.strip(), m.getDecl().split('\n'))
        return '\n'.join(lines)

    def getMVarDecl(self):
        logging.debug('mvar decl for %s', self.name)
        lines = []
        self.variables.sort(lambda x, y: cmp(x.access, y.access))
        for access, g in itertools.groupby(self.variables, lambda m : m.access):
            lines.append('%s:'%access)
            for m in g:
                lines.append('    %s'%m.getDecl())
        return '\n'.join(lines)

    @staticmethod
    def from_src(src):
        cds = {}
        logging.debug('ClassDef from_src')
        for mm in MemberMethod.from_src(src):
            cd = None
            if mm.clz not in cds:
                cd = ClassDef()
                cd.name = mm.clz
                cds[mm.clz] = cd
            else:
                cd = cds[mm.clz]
            cd.methods.append(mm)

        for mv in MemberVar.from_src(src):
            cd = None
            if mv.clz not in cds:
                cd = ClassDef()
                cd.name = mv.clz
                cds[mv.clz] = cd
            else:
                cd = cds[mv.clz]
            cd.variables.append(mv)
        return cds

class FunctionDef(object):
    tag_re = re.compile(r'//\s*H_Function\b.*$', re.MULTILINE)
    func_re = re.compile(r'(?P<return_type>[\w:]+(?:\w+\s+)*\s*[\w\*&<:>&]*\s+)(?:[\w:]+::)?(?P<name>[^:()\s]+)\s*(?P<args>\([^()]*\))', re.MULTILINE)
    def __init__(self, name=None, return_type=None, args=None):
        self.name = name
        self.return_type = return_type
        self.args = args

    def getDecl(self):
        pass

    def __str__(self):
        return str(vars(self))

    def getDecl(self):
        return '%s %s %s;'%(self.return_type, self.name, self.args)

    @staticmethod
    def from_src(src):
        functions = []
        for tagm in FunctionDef.tag_re.finditer(src):
            f = FunctionDef()
            fm = FunctionDef.func_re.search(src, tagm.end())
            if fm:
                f.name = xstr(fm.group('name'))
                f.return_type = xstr(fm.group('return_type'))
                f.args = xstr(fm.group('args'))
                functions.append(f)
        return functions

def makeClassTemplate(clz):
    pair = map(str.strip, clz.split(':'))
    name = pair[0]
    parent = ''
    if len(pair) > 1:
        parent = ' : '+pair[1]
    t = string.Template('''class $clz$parent
{
//H_MethodDeclare $clz 
//H_MVarDeclare $clz
};
''')
    r = t.substitute(clz=name, parent=parent)
    return r

def main():
    aparse = argparse.ArgumentParser()
    aparse.add_argument('-l', '--loglevel', default='INFO')
    aparse.add_argument('inputs', nargs='+')

    args = aparse.parse_args()

    logging.getLogger().setLevel(eval('logging.%s'%args.loglevel.upper()))

    for f in args.inputs:
        bname, ext = os.path.splitext(f)
        outf = bname + '.h'
        content = ''
        if os.path.exists(outf):
            with open(outf) as fp:
                content = fp.read()
            if not content.startswith('//HGEN'):
                logging.info('%s is not managed by HGEN, skip it'%outf)
                continue
        with open(f) as fp:
            src = CodeFile(fp.read())
        h = src.genHeader(outf)
        if content == h:
            logging.info("No change to header %s", outf)
            return
        with open(outf, 'w') as fp:
            fp.write(h)
        logging.info('write to %s', outf)


if __name__ == '__main__':
    main()



