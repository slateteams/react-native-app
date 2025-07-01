#!/usr/bin/env ruby

require 'xcodeproj'
require 'pathname'

# Parse command line arguments
project_path = nil
target_name = nil
dry_run = false
files_to_add = []

ARGV.each_with_index do |arg, index|
  case arg
  when '--project'
    project_path = ARGV[index + 1]
  when '--target'
    target_name = ARGV[index + 1]
  when '--dry-run'
    dry_run = true
  else
    # Skip if it's a parameter value
    next if index > 0 && ['--project', '--target'].include?(ARGV[index - 1])
    
    # Add files (support glob patterns)
    if arg.include?('*')
      files_to_add.concat(Dir.glob(arg))
    else
      files_to_add << arg
    end
  end
end

# Auto-detect project if not specified
if project_path.nil?
  project_files = Dir.glob('*.xcodeproj')
  if project_files.length == 1
    project_path = project_files.first
    puts "Auto-detected project: #{project_path}"
  elsif project_files.length > 1
    puts "Multiple .xcodeproj files found. Please specify with --project:"
    project_files.each { |f| puts "  #{f}" }
    exit 1
  else
    puts "No .xcodeproj file found. Please specify with --project."
    exit 1
  end
end

# Validate inputs
if files_to_add.empty?
  puts "Usage: #{$0} [--project PATH] [--target NAME] [--dry-run] <files...>"
  puts ""
  puts "Options:"
  puts "  --project PATH    Path to .xcodeproj file (auto-detected if only one exists)"
  puts "  --target NAME     Target name (uses first target if not specified)"
  puts "  --dry-run         Show what would be done without making changes"
  puts ""
  puts "Examples:"
  puts "  #{$0} MyFile.swift"
  puts "  #{$0} --target MyApp Source/*.swift"
  puts "  #{$0} --dry-run MyFile.swift MyFile.m"
  exit 1
end

# Validate files exist
missing_files = files_to_add.reject { |f| File.exist?(f) }
unless missing_files.empty?
  puts "Error: These files don't exist:"
  missing_files.each { |f| puts "  #{f}" }
  exit 1
end

# Filter to only Swift/Objective-C files
valid_extensions = ['.swift', '.m', '.mm', '.h']
files_to_add.select! do |file|
  ext = File.extname(file).downcase
  valid_extensions.include?(ext)
end

if files_to_add.empty?
  puts "No Swift or Objective-C files found to add."
  exit 0
end

puts "Files to add:"
files_to_add.each { |f| puts "  #{f}" }
puts ""

if dry_run
  puts "DRY RUN: Would add #{files_to_add.length} files to #{project_path}"
  exit 0
end

# Open the project
begin
  project = Xcodeproj::Project.open(project_path)
rescue => e
  puts "Error opening project: #{e.message}"
  exit 1
end

# Get target
target = if target_name
  project.targets.find { |t| t.name == target_name }
else
  project.targets.first
end

unless target
  if target_name
    puts "Target '#{target_name}' not found. Available targets:"
  else
    puts "No targets found in project. Available targets:"
  end
  project.targets.each { |t| puts "  #{t.name}" }
  exit 1
end

puts "Using target: #{target.name}"

# Add files to project
files_to_add.each do |file_path|
  begin
    # Create group hierarchy based on file location
    file_pathname = Pathname.new(file_path)
    relative_path = file_pathname.relative_path_from(Pathname.new(Dir.pwd))
    
    # Create group hierarchy
    group = project.main_group
    relative_path.dirname.each_filename do |dir_name|
      next if dir_name == '.'
      
      existing_group = group.children.find { |child| child.display_name == dir_name && child.isa == 'PBXGroup' }
      if existing_group
        group = existing_group
      else
        group = group.new_group(dir_name)
      end
    end
    
    # Check if file already exists in project
    existing_file = project.files.find { |f| f.real_path == File.absolute_path(file_path) }
    if existing_file
      puts "  #{file_path} - already in project, skipping"
      next
    end
    
    # Add file to group
    file_ref = group.new_reference(file_path)
    
    # Add to target's build phases if it's a source file
    case File.extname(file_path).downcase
    when '.swift', '.m', '.mm'
      target.source_build_phase.add_file_reference(file_ref)
      puts "  #{file_path} - added to sources"
    when '.h'
      puts "  #{file_path} - added as header"
    end
    
  rescue => e
    puts "  #{file_path} - error: #{e.message}"
  end
end

# Save the project
begin
  project.save
  puts ""
  puts "Successfully updated #{project_path}"
rescue => e
  puts "Error saving project: #{e.message}"
  exit 1
end 