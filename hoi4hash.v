module main

import os
import crypto.md5

const (
	gamedir = get_gamedir()
)

fn get_default_gamedir() string {
	$if windows {
		return 'C:\\Program Files\\Steam\\steamapps\\common\\Hearts of Iron IV\\'
	}
	$if linux {
		home := os.getenv('HOME')
		return '$home/.local/share/Steam/steamapps/common/Hearts of Iron IV/'
	}
	panic('incompatible OS')
}

fn get_gamedir() string {
	return get_default_gamedir()
}

fn get_vanilla_checksum() string {
	mut digest := md5.new()
	for entry in parse_manifest() {
		for file in entry.get_files(false) {
			digest.write(file.replace(gamedir, '').bytes())
			data := os.read_bytes(file) or {
				eprintln(err)
				continue
			}
			digest.write(data)
		}
	}
	return digest.sum([]).hex()
}

fn main() {
	println(get_vanilla_checksum())
}
