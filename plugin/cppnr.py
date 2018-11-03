'''
This is a neovim's remote plugin
'''
import neovim
import string
import os.path
import os
import shutil
import re

@neovim.plugin
class CPPNRPlugin(object):

    def __init__(self, nvim):
        self.nvim = nvim

    @neovim.autocmd('VimEnter', sync=True)
    def onEnter(self):
        self.nvim.command('nmap <Leader>ic :call CCInsIncl("cpp", "insert")<CR>')
        self.nvim.command('nmap <Leader>ih :call CCInsIncl("h", "insert")<CR>')
        self.nvim.command('nmap <Leader>gic :call CCInsIncl("cpp", "goto")<CR>')
        self.nvim.command('nmap <Leader>gih :call CCInsIncl("h", "goto")<CR>')

    @neovim.command('Mkcls', nargs='*', complete='dir', sync=True)
    def makeClass(self, args):
        path = args[0]
        self.nvim.out_write(path + '\n')
        di = os.path.dirname(path)
        if di and not os.path.exists(di):
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

        self.nvim.command(':e %s'%cppname)
        self.nvim.command('normal Gka')


    @neovim.command('Rmcls', nargs='*', complete='dir', sync=True)
    def rmClass(self, args):
        def mv2tmp(src):
            if os.path.exists(src):
                base = os.path.basename(src)
                dst = os.path.join('/tmp', base)
                shutil.move(src, dst)

        path = self.nvim.eval('@%')
        path = os.path.splitext(path)[0]
        path = os.path.abspath(path)
        cppname = '%s.cpp'%path
        hname = '%s.h'%path

        mv2tmp(cppname)
        mv2tmp(hname)

#clear buffers
        for f in [cppname, hname]:
            if self.nvim.current.buffer.name != f:
                self.nvim.command('silent! bd! %s'%f)
            else:
                self.nvim.command('normal ,q')

    @neovim.function('CCInsIncl', sync=True)
    def insertInclude(self, args):
        f = args[0]
        action = args[1]
        word = self.nvim.eval('expand("<cword>")')
        if word.strip():
            line = 0
            hdrStart, hdrEnd = 0, 0
            for n, l in enumerate(self.nvim.current.buffer):
                if l.find('H_Declare') >= 0:
                    hdrStart = n
                    break
            for c, l in enumerate(self.nvim.current.buffer[n:], n):
                if l.find('*/') >= 0:
                    hdrEnd = c
                    break
            start, end = hdrStart, hdrEnd
            if f == 'cpp':
                start = hdrEnd
                end = min(start + 50, len(self.nvim.current.buffer)-1)
            for i in range(end, start, -1):
                l = self.nvim.current.buffer[i]
                if l.find('#include') >= 0:
                    line = i
                    break
            self.nvim.out_write('{}\n'.format(line))
            if action == 'goto':
                self.nvim.command('normal %sgg'%(line+1))
            elif action == 'insert':
                direc = '#include "%s.h"'%word
                if word in 'string map vector set list unordered_map unordered_set'.split():
                    direc = '#include <%s>'
                exists = False
                for l in self.nvim.current.buffer[start:line+1]:
                    if l.find(direc) >= 0:
                        exists = True
                        break

                if not exists:
                    self.nvim.current.buffer.append(direc, line+1)
                    self.nvim.command('normal j')
                else:
                    self.nvim.out_write('header has already been included')

