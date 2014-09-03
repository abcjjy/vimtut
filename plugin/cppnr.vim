
if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! CCMakeClass(path)
    python << EOF
import vim
import string
import os.path
import os

path = vim.eval('a:path')
di = os.path.dirname(path)
if not os.path.exists(di):
    os.makedirs(di)

tpl = string.Template('''/*H_Declare
#include "cocos2d.h"
#include "cocos-ext.h"
#include <string>
#include <vector>
#include <map>
USING_NS_CC;
USING_NS_CC_EXT;

class $name
{
//H_MethodDeclare $name
//H_MVarDeclare $name
};
*/
#include "$name.h"
using namespace std;



''')
cppname = '%s.cpp'%path
if not os.path.exists(cppname):
    name = os.path.basename(path)

    plate = tpl.substitute(name=name)

    with open(cppname, 'w') as p:
        p.write(plate)

vim.command(':e %s'%cppname)
vim.command('normal Gka')

EOF
endfunction

function! CCRmClass()
    python << EOF
import vim
import os.path
import shutil

def mv2tmp(src):
    if os.path.exists(src):
        base = os.path.basename(src)
        dst = os.path.join('/tmp', base)
        shutil.move(src, dst)

path = vim.eval('@%')
path = os.path.splitext(path)[0]
path = os.path.abspath(path)
cppname = '%s.cpp'%path
hname = '%s.h'%path

mv2tmp(cppname)
mv2tmp(hname)

#clear buffers
for f in [cppname, hname]:
    if vim.current.buffer.name != f:
        vim.command('silent! bd! %s'%f)
    else:
        vim.command('normal ,q')

EOF
endfunction

"quick add #include directive
function! CCInsIncl(file, action)
    python << EOF
import vim
import re
f = vim.eval("a:file")
action = vim.eval('a:action')
word = vim.eval('expand("<cword>")')
if word.strip():
    line = 0
    hdrStart, hdrEnd = 0, 0
    for n, l in enumerate(vim.current.buffer):
        if l.find('H_Declare') >= 0:
            hdrStart = n
            break
    for c, l in enumerate(vim.current.buffer[n:], n):
        if l.find('*/') >= 0:
            hdrEnd = c
            break
    start, end = hdrStart, hdrEnd
    if f == 'cpp':
        start = hdrEnd
        end = min(start + 50, len(vim.current.buffer)-1)
    for i in range(end, start, -1):
        l = vim.current.buffer[i]
        if l.find('#include') >= 0:
            line = i
            break
    print line
    if action == 'goto':
        vim.command('normal %sgg'%(line+1))
    elif action == 'insert':
        direc = '#include "%s.h"'%word
        if word in 'string map vector set list unordered_map unordered_set'.split():
            direc = '#include <%s>'
        exists = False
        for l in vim.current.buffer[start:line+1]:
            if l.find(direc) >= 0:
                exists = True
                break

        if not exists:
            vim.current.buffer.append(direc, line+1)
            vim.command('normal j')
        else:
            print 'header has already been included'
EOF
endfunction

command! -nargs=1 -complete=dir Mkcls call CCMakeClass(<f-args>)
command! -nargs=0 Rmcls call CCRmClass()
nmap <Leader>ic :call CCInsIncl("cpp", "insert")<CR>
nmap <Leader>ih :call CCInsIncl("h", "insert")<CR>
nmap <Leader>gic :call CCInsIncl("cpp", "goto")<CR>
nmap <Leader>gih :call CCInsIncl("h", "goto")<CR>

