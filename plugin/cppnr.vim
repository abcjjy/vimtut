
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
os.makedirs(di)

tpl = string.Template('''/*H_Declare
#include "cocos2d.h"
#include "cocos-ext.h"
#include <string>
#include <vector>
#include <map>
USING_NS_CC;
USING_NS_CC_EXT;

//H_Class $name
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

command! -nargs=1 -complete=dir Mkcls call CCMakeClass(<f-args>)
command! -nargs=0 Rmcls call CCRmClass()

