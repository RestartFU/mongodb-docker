module main

import os

const docker_compose = $embed_file('./docker-compose.yml')
const options := [
  Opt{name: "start", description: "starts the mongodb-docker server"}
  Opt{name: "stop",  description: "stops the mongodb-docker server"}
]

fn main() {
  os.rmdir_all("/tmp/mongodb-docker")!
  os.mkdir("/tmp/mongodb-docker")!
  os.write_file("/tmp/mongodb-docker/docker-compose.yml", docker_compose.to_string())!

  mut args := os.args.clone()[1..]
  mut background := false

  for i, arg in args {
    if arg == "--background" {
      background = true
      args.delete(i)
      break
    }
  }

  if args.len < 1 {
    man("mongodb-docker manual", ...options)
    return
  }

  if !valid_opt(args[0], ...options) {
    man("unknown option '${args[0]}'; mongodb-docker manual", ...options)
    return
  }

  mut kind := "up"
  if args[0] == "stop" {
    kind = "down"
  }

  mut cmd := "docker compose -f /usr/local/mongodb-docker/docker-compose.yml ${kind} 2>/dev/null"
  if background { cmd += " & disown" }

  println(cmd)
  os.system(cmd)
}

struct Opt {
  name string
  description string
}

fn valid_opt(opt string, opts ...Opt) bool {
  for o in opts {
    if o.name == opt {
      return true
    }
  }
  return false
}

fn man(err string, opts ...Opt) {
  println("${err}:")

  mut longest_name_length := 0
  for o in opts {
    length := o.name.len
    if length > longest_name_length {
      longest_name_length = length
    }
  }

  for o in opts {
    length_diff := longest_name_length - o.name.len
    mut name := o.name
    name += " ".repeat(length_diff)

    println("       ${name}   ${o.description}")
  }
}
