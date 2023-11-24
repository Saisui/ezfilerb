# frozen_string_literal: true
require_relative "Ezfile/version"
require 'colorize'

module Ezfile
  class Error < StandardError; end
  # Your code goes here...
end

module Ezfile
  class << self

  # == Exception ==
  # -[x] Dest Dir has a SAME NAME node | 目的地文件夹内存在同名文件/文件夹（节点）
  # -[x] Source File doesn't exist | 源文件不存在
  # -[x] Dest Dir doesn't exist | 目的地文件夹不存在
  # -[x] Path String has a space character | 路径名包含空格
  # -[ ] Abs Path Cannot with Relative Path | 绝对路径不能与相对路径组合

  # nut_a.black.you.one

  def test_rebasename path, new_basename
    File.join(File.dirname(File.expand_path(path)), new_basename + File.extname(path))
  end

  # -[x] cannot move file or change its parent node | 重命名不改变源文件父节点，不移动源文件。
  def rebasename_file nodepath, new_basename

    if new_basename.split(/[\/\\]/).size == 0
      return throw puts  "  wrong  ".on_light_yellow + " That's no new basename"
    elsif new_basename.split(/[\/\\]/).size >= 2
      return throw puts  "  FORBIDDEN  ".light_white.on_yellow + " do not move its parent node, don't input a path"
    end

    src_dirpath = File.dirname File.expand_path(nodepath)

    unless File.exist? nodepath
      return throw puts  "  ERROR  ".light_white.on_red + " File " + "non-exist".red
    end
    new_name = new_basename + File.extname(nodepath)
    unless Dir.entries(File.dirname nodepath).include? new_name
      File.rename nodepath, File.join(src_dirpath, new_name)
    end
  end

  # < means headpoint of a basename, > means lastpoint of a basename. like ^ and $ in RegEx
  # basename   <name.dot1.dot2.ext>
  # tailname   .dot1.dot2.ext>    # [A-Za-z_\-\.]*$
  # mainname   <name    .dot1.dot2
  # headname   <name

  def tailname fname
    Ezfile.basename(fname).match(/((\.[0-9A-Za-z\-_]+)+$)/)[0]
  end
  def tailnames fname
    Ezfile.basename(fname).match(/((\.[0-9A-Za-z\-_]+)+$)/)[0].split(/(?=\.)/)
  end

  def headname fname
    File.basename(fname)[0...-tailname(fname).size]
  end

  def mainname file_name
    File.basename file_name, ".*"
  end


  def its_dir_base_ext file_path
    [File.dirname(file_path), File.basename(file_path, ".*"), File.extname(file_path)]
  end

  def basename file_name, suffix = ""
    File.basename file_name, suffix
  end

  def move_file file_path, target_dir, mkdir: false, rename: false, rename_fmt: "__%C"
    unless File.exist? file_path
      return throw puts "  ERROR  ".light_white.on_red + " File " + "non-exist".red
    end
    file_name = File.basename file_path

    # src_exist = File.exist? file_path
    # src_is_file = File.file? file_path rescue false
    # dest_exist = Dir.exist? target_dir
    # dest_is_dir = File.directory? target_dir rescue false
    # not_same_name = target_dir_entries.include? file_name rescue false

    isit_should_move = false

    if Dir.exist? target_dir
      target_dir_entries = Dir.entries target_dir
      if target_dir_entries.include? file_name
        if rename == true

          rename_count = 0
          # nDigits = rename_fmt.count("#")
          begin
            rename_count += 1
            # rename_postfix = rename_fmt.gsub(/#*/, "%0#{nDigits}d" % rename_count)
            src_dirpath, file_basename, file_ext = its_dir_base_ext(file_path)
            new_basename = file_basename + "__mv_rename_#{rename_count}"
            new_name = new_basename + file_ext

            new_name_file_path = File.join(src_dirpath, new_name)
          end while target_dir_entries.include? new_name

          rebasename_file(file_path, new_basename)
          return move_file(new_name_file_path, target_dir)
        end
        return throw puts  "  ERROR  ".light_white.on_red + %Q(   === Destination already has a same name node! -- "#{file_name.red}" ===)
      end
      isit_should_move = true
    elsif mkdir == true
      Dir.mkdir target_dir
      isit_should_move = true
    else
      return throw puts  "  ERROR  ".light_white.on_red + " Destination Directory doesn't exist!"
    end

    if isit_should_move
      FileUtils.move file_path, target_dir
    end
  end

  def copy_file file_path, dest_file_path
    if File.exist? dest_file_path
      return throw puts  "  FORBIDDEN  ".light_white.on_yellow + " There is a same name node, cannot " + " COVER ".light_white.on_red.bold + " another existen node, Because will " + " LOSE ".light_white.on_red + " the FILE."
    end
    FileUtils.copy_file file_path, dest_file_path
  end

  def move_file_mkdir file_path, target_dir
    self.move_file file_name, target_dir, mkdir: true
  end

  def file_list dir = "*"
    Dir.glob(dir).select{File.file? _1}
  end

  def dir_list dir = "*"
    Dir.glob(dir).select{File.directory? _1}
  end

  alias files file_list
  alias dirs dir_list
  alias movefile move_file
  alias movefile_mkdir move_file_mkdir
  alias copyfile copy_file

  def glob query
      Dir.glob(query)
  end

  def ensure_permanently_delete_file file_path
      if File.file? file_path
          FileUtils.remove_file file_path
      end
  end
  def ensure_permanently_delete_directory_and_its_descendant dir_path
      if File.direcotry? dir_path
          FileUtils.remove_dir dir_path
      end
  end

  def help
    puts <<-EOF
            require #{"FileUtils".red} and #{"Dir".red}, #{"File".red}.
        methods:
        #{" MOVE ".bold.underline.on_red}:
        #{"::move_file".cyan} file_path target_dir, mkdir: false
            move file to target directory
            ! if directory is non-exist,
            throw an error.
        #{"::move_file ".cyan} file_path, target_dir
            if non-exist, mkdir
        #{" QUERY ".bold.underline.on_green}:   its syntax like #{"Explorer Search".underline}
        #{"::file_list ".cyan} target_dir = "*"     alias #{"::files".cyan}
        #{"::dir_list ".cyan} target_dir = "*"      alias #{"::dirs".cyan}
            show list of files/directories, of target_dir.
            ! using #{"Dir.glob(target_dir)".italic.underline.yellow}
        #{"::its_dir_base_ext ".cyan} file_path
            return an array of file's dirpath basename extname.
        #{"::glob".cyan} query
            the same as #{"Dir.glob(query)".italic.underline.yellow}

        #{" RENAME ".bold.underline.on_yellow}:
        #{"::rebasename_file".cyan} src_file_path, new_basename
            it change a file's basename, and ensure never move it or change its parent node.

        #{" DELETE ".bold.underline.on_red}:
            #{"::ensure_permanently_delete_file".cyan} target_file     alias #{"::files".cyan}
            #{"::ensure_permanently_delete_directory_and_its_descendant".cyan} target_dir     alias #{"::files".cyan}
    EOF
  end

  end
end

class String

  def to_file_ezfile fpath = "file_" + Time.now.strftime("%y%m%s_%H%M%S") + ".txt"
    if File.exist?(fpath)
      puts ""
      return throw puts  "  ERROR  ".light_white.on_red + " Destination Directory doesn't exist!"
    else
      f = File.new(fpath, "w")
      f.puts self
      f.close
    end
  end
end
