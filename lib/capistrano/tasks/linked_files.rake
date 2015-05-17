namespace :linked_files do

  desc 'Upload linked files and directories'
  task :upload do
    invoke 'linked_files:upload:files'
    invoke 'linked_files:upload:dirs'
  end
  task :upload_files do
    invoke 'linked_files:upload:files'
  end
  task :upload_dirs do
    invoke 'linked_files:upload:dirs'
  end

  namespace :upload do

    task :files do
      on roles :web do
        fetch(:linked_files).each do |local_path|
          remote_path = "#{shared_path}/#{local_path}"
          remote_md5 = (capture "md5sum #{remote_path} | awk '{print $1}'").strip!
          local_md5 = (`md5sum #{local_path} | awk '{print $1}'`).strip!
          puts "Local md5: " + local_md5
          puts "Remote md5: " + remote_md5
          puts "Are they the same? " + (local_md5 == remote_md5).to_s
          if local_md5 != remote_md5
            upload! local_path, "#{shared_path}/#{local_path}"
          end
        end
      end
    end

    task :dirs do
      on roles :web do
        fetch(:linked_dirs).each do |dir|
          upload! dir, "#{shared_path}/", recursive: true
        end
      end
    end

  end

  before 'linked_files:upload', 'deploy:check:make_linked_dirs'

end
