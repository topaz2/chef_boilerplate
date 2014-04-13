Description
===========
This cookbook's goal is to provide the best and dead simple way to start new web application project.

Containing following

| Category | Application |
| ------- | ---------- |
| HTTP Server | apache |
| DB | mysql |
| BTS | redmine |
| CI | jenkins |
| VCS | git, subversion |
| Editor | emacs, vim |
| Utils | guard, jasmine, juicer, etc... |

Requirements
============
* Chef: 11.x+

Attributes
==========

Usage
=====

## How to use in a recipe
```
include_recipe 'boilerplate'
```
## Configuration
### Clone git repository and install everything into example.com
```
$ cat nodes/example.json
{
    "boilerplate": {
        "git": {
            "uri": "https://github.com/your/repo"
        },
        "redmine": {
            "host": "example.com",
            "path": "/redmine"
        },
        "jenkins": {
            "host": "example.com",
            "path": "/jenkins"
        }
    }
}
```

### Stop installing specific applicaiton
e.g.) Stop installing jenkins
```
$ cat nodes/example.json
{
    "boilerplate": {
        "jenkins": false
    }
}
```

### Set /vagrant as DocumentRoot for vagrant
```
$ cat nodes/example.json
{
    "boilerplate": {
        "document_root": "/vagrant"
    }
}
```

License and Authors
===================

* Author:: Jun Nishikawa <topaz2@m0n0m0n0.com>

* Copyright (C) 2014, Jun Nishikawa <topaz2@m0n0m0n0.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

