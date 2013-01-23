Nancy with Make & Mono
======================

- Coded in Nancy
- Compiled with Mono 2.10.9
- Built with Make 3.81
- Hosted by a Self Contained EXE

This project is using a package.config to simulate nuget.  It's using wget to download specific package versions.  The make file is not pretty.  But it works.

Dependencies
------------

### Make 3.81
### Mono 2.10.9

Usage
-----

```
% make clean

% make

% make run

% make run URL=http://localhost:8080
```
