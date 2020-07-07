module main

import os

const (
	manifest_dir = os.join_path(get_gamedir(), 'checksum_manifest.txt')
)

struct ManifestEntry {
mut:
	name            string = ''
	sub_directories bool = false
	file_extension  string = ''
}

fn (entry ManifestEntry) get_files(include_mods bool) []string {
	if entry.sub_directories {
		return os.walk_ext(gamedir + entry.name, entry.file_extension)
	} else {
		files := os.ls(gamedir + entry.name) or {
			return []
		}
		return files.filter(it.ends_with(entry.file_extension))
	}
}

fn split(text string) (string, string) {
	splitted := text.split('=')
	return splitted[0].trim_right(' '), splitted[1].trim_left(' ')
}

fn parse_manifest() []ManifestEntry {
	manifest := os.read_lines(manifest_dir) or {
		eprintln(err)
		exit(1)
	}
	mut entries := []ManifestEntry{}
	for line in manifest {
		match line {
			'' {}
			'directory' {
				entries << ManifestEntry{}
			}
			else {
				key, value := split(line)
				match key {
					'name' {
						entries[entries.len - 1].name = value
					}
					'file_extension' {
						entries[entries.len - 1].file_extension = value
					}
					'sub_directories' {
						if value.to_lower() == 'yes' {
							entries[entries.len - 1].sub_directories = true
						} else {
							entries[entries.len - 1].sub_directories = false
						}
					}
					else {
						eprintln('Skipping unrecognized option: $key = $value')
					}
				}
			}
		}
	}
	return entries
}
