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
    if(parts[0] in names) {
      id = names[parts[0]];
      files[id].idx ~= to!int(parts[1]);
      files[id].lines ~= parts[3];
    } else {
      names[parts[0]] = i;
      id = i;
      fed fd;
      fd.idx ~= to!int(parts[1]);
      fd.lines ~= parts[3];
      files ~= fd;
      i += 1;
    }
  }
  f.close;
}
