#!/usr/bin/env ruby

require 'open3'
require 'pp'
require 'rubygems'
require 'xcodeproj'

project_path = [Dir.pwd, Dir.new(Dir.pwd).find { |path|
  [".xcodeproj"].include? File.extname(path).downcase
}].join("/")

project = Xcodeproj::Project.new project_path
project_name = File.basename(project_path, ".xcodeproj")
resources_group = project.groups.find { |group| group.name == "Resources" }
resources_group_path = resources_group.path
resources_group_pathname = Pathname.new([Dir.pwd, resources_group_path].join("/"))

if ARGV.empty?
  target_name = project_name
else
  target_name = ARGV.first
end

target = project.targets.find { |target| target.name == target_name }

resources_build_phase = target.resources_build_phase

resource_file_paths = []

Dir.new(resources_group_path).each { |path|
  if [".png"].include? File.extname(path).downcase
    file_path = [Dir.pwd, resources_group_path, path].join("/")
    resource_file_paths << file_path
  end
}

removed_files = []
added_paths = resource_file_paths.dup

resources_group.files.each { |file|

  file_path = (file.source_tree == "<group>") ?
    [Dir.pwd, resources_group_path, file.pathname.basename].join("/")  :
      file.pathname.basename

  pathname = Pathname.new(file_path)
  unless pathname.exist?
    removed_files << file
  end

  added_paths.delete file_path

}

removed_files.each { |removed_file|

  group = removed_file.group
  removed_file.referrers.dup.each { |referrer|
    if referrer.isa == "PBXBuildFile"
      referrer.remove_from_project
    end
    removed_file.remove_referrer referrer
  }

  removed_file.remove_from_project
  group.children.delete removed_file

  raise "can not have the group still containing the file" if resources_group.files.include? removed_file

}

added_files = []
added_paths.each { |added_path|
  added_file_path = (Pathname.new(added_path)).relative_path_from(resources_group_pathname).to_s
  added_file = resources_group.new_file(added_file_path)
  added_file.source_tree = "<group>"
  resources_build_phase.add_file_reference(added_file)
  added_files << added_file
}

project.save_as(project_path)

# Convert the plist back to old-style

stdin, stdout, stderr = Open3.popen3("pl -input #{project_path}/project.pbxproj")
lines = stdout.readlines

project_file = File.open("#{project_path}/project.pbxproj", 'w') { |file|
  lines.each { |line|
    file.write(line)
  }
}
