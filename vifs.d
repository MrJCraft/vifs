import std.stdio;
import std.file;
import std.parallelism;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

//(.*(?:hello).*)

struct fed {
  int[] idx;
  string[] lines;
}

fed[] files;
int[string] names;


void main(string[] args) {
  string name = args[1];
  setup(name);
  distribute();
}

void distribute() {
  foreach(v, i; names) {
    //if file doesnt exist use empty array
    string[] contents;
    if(v.exists) {
      contents = readText(v).split("\n");
    }
    fed def = files[i];
    foreach(j, l; def.lines) {
      int id = def.idx[j];

      if(id >= contents.length) {contents ~= new string[id-contents.length];}

      contents[id-1] = l;
    }
    File f = File(v, "w");
    foreach(line; contents) {
      f.writeln(line.strip);
    }
    f.close;
  }
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
    string[] parts = line.split(":");
    string pline = line.parse;
    if(parts[0] in names) {
      id = names[parts[0]];
      files[id].idx ~= to!int(parts[1]);
      files[id].lines ~= pline;
    } else {
      names[parts[0]] = i;
      id = i;
      fed fd;
      fd.idx ~= to!int(parts[1]);
      fd.lines ~= pline;
      files ~= fd;
      i += 1;
    }
  }
  f.close;
}

string parse(string line) {
  int total, j = 0;
  foreach(c;line){
    if(c == ':') {
      total++;
    }
    if(total == 3) {
      return line[j+1..$];
    }
    j++;
  }
  assert(0, "Parse Error, not enough ':' need 3 name:line-num:1:line");
}
