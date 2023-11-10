# Ezfile

Ezfile is a file util more safety than another gem `FileUtils`

`copy_file` , `mainname`, `move_file`, `rename`, `remainame`

## Installation


    gem install ezfile


## Usage

```ruby
require 'ezfile'

pwd = Dir.pwd

Ezfile.files("*")
  .group_by{|fname| Ezfile.mainname}
  .select{|mname, fs| fs.any{|f| Ezfile.extname(f) == ".ass"}}
  .each do |fname, fs|
     ass = File.combine(pwd, fname +".ass")
     mp4 = File.combine(pwd, fname +".mp4")
     outf = fname+".done.mp4"
     system %Q(ffmpeg -i #{mp4.inspect} -vf subtitles=#{ass.inspect} -c:v h264_nvenc "./out/#{outf}")
  end
```
Use `Ezfile.help` to get help.
```ruby
Ezfile.help

<<-EOF
              require FileUtils and Dir, File.
          methods:
           MOVE :
          ::move_file file_path target_dir, mkdir: false
              move file to target directory
              ! if directory is non-exist,
              throw an error.
          ::move_file  file_path, target_dir
              if non-exist, mkdir
           QUERY :   its syntax like Explorer Search
          ::file_list  target_dir = "*"     alias ::files
          ::dir_list  target_dir = "*"      alias ::dirs
              show list of files/directories, of target_dir.
              ! using Dir.glob(target_dir)
          ::glob query
              the same as Dir.glob(query)

           RENAME :
          ::rebasename_file src_file_path, new_basename
              it change a file's basename, and ensure never move it or change its parent node.

           DELETE :
            ::ensure_permanently_delete_file target_file     alias ::files
            ::ensure_permanently_delete_directory_and_its_descendant target_dir     alias ::files
EOF
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saisui/ezfilerb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/saisui/ezfilerb/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

