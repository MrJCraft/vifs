import std.stdio;
import std.file;
import std.parallelism;
import std.string;
import std.conv;
import std.algorithm;
import std.algorithm.searching;
import std.array;

// (.*(?:hello).*)
// Name:line-num:cmd:text
//                ^

bool rep = true;
// if any any commands are executed they it will duplicate lines
// only useful for a onetime execute

// TODO add Range Syntax
// TODO g and G
// decide if I am removing the not deterministic features

struct fed {
  int[] idx;
  string[] lines;
  string[] cmd;
}

fed[] files;
int[string] names;


void main(string[] args) {
  if(args.length > 1) {
    string name = args[1];
    setup(name);
    if(!rep) {
      writeln("vifs file uses Insert mode, and is no longer reproducible");
      writeln("if you execute this same file again you will be duplicating the line every time");
    }
    distribute();
  } else {
    writeln("Error: no input file");
  }
}

// TODO this one is a time waster
void distribute() {
  foreach(v, i; names) {
    string[] contents;
    if(v.exists) {
      contents = readText(v).split("\n");
    }
    fed def = files[i];
    foreach(j, l; def.lines) {
      int id = def.idx[j];
      string mode = def.cmd[j];
      if(id >= contents.length) {contents ~= new string[id-contents.length];}
      if(mode == "1") {
        contents[id-1] = l;
      } else if(mode == "a") {
        contents ~= "";
        contents[id] ~= l;       
      } else if(mode == "i") {
        if(id > 1) {
        contents[id-2] ~= l;
        } else if(id == 1) {
          contents ~= "";
          contents[1] ~= contents[0];
          contents[0] = l;
        }
      }
    }
    int dis = v.findLast('/');
    if(dis != -1 && !v[0..dis].exists) {
          mkPath(v);
    }
    File f = File(v, "w");
    foreach(line; contents) {
          if(line.length < 1) {
                f.writeln();
          } else {
                f.writeln(line[0..$-1]);
          }
    }
    f.close;
  }
}

int findLast(string line, char find) {
      foreach_reverse(i, v; line) {
            if(v == find) {
                  return cast(int) i;
            }
      }
      return -1;
}

void setup(string filename) {
  File f = File(filename, "r");
  int i = 0;
  string line;
  int id = 0;
  while(!f.eof) {
    line = f.readln();
    if(line.length < 7) {
      continue;
    }
    string[4] parts = parseline(line);
    if(parts[0] in names) {
      id = names[parts[0]];
      files[id].idx ~= to!int(parts[1]);
      files[id].lines ~= parts[3];
      files[id].cmd ~= parts[2];
      if(parts[2] == "a" || parts[2] == "i") {
        rep = false;
      }
    } else {
      names[parts[0]] = i;
      id = i;
      fed fd;
      fd.idx ~= to!int(parts[1]);
      fd.lines ~= parts[3];
      fd.cmd ~= parts[2];
      files ~= fd;
      i += 1;
    }
  }
  f.close;
}

string[4] parseline(string line) {
  int total = 0;
  ulong[] pos;
  foreach(i, c; line) {
    if(c == ':') {
      pos ~= i;
    }
  }
  assert(total < 3, "Parse Error, not enough ':' need 3 name:line-num:1:line");
  string first = line[0..pos[0]];
  string second = line[pos[0]+1..pos[1]];
  string third = line[pos[1]+1..pos[2]];
  string fourth = line[pos[2]+1..$];
  return [first, second, third, fourth];
}


void mkPath(string path) {
  ulong[] pos;
  foreach(i, c; path) {
    if(c == '/') {
      pos ~= i;
    }
  }
  if(pos.length > 0) {
    foreach(p; pos) {
      path[0..p].mkdir;
    }
  }
}
