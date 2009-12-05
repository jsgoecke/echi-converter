class FtpFetcher < Net::FTP
  
  #Connect to the ftp server
  def connect_ftp_session log
    begin
      #ftp_session = Net::FTP.new($config["echi_host"])
      ftp_session = Net::FTP.new
      ftp_session.connect($config["echi_host"], $config["echi_port"])
      ftp_session.login $config["echi_username"], $config["echi_password"]
      log.info "Successfully connected to the ECHI FTP server"
    rescue => err
      log.info "Could not connect with the FTP server - " + err
      return -1
    end
    return ftp_session
  end
  
  #Obtain the list of files available on the server
  def fetch_list log
    attempts = 0
    ftp_session = -1
    while ftp_session == -1 do
      ftp_session = connect_ftp_session log
      if ftp_session == -1
        sleep 5
      end
      attempts += 1
      if $config["echi_ftp_retry"] == attempts
        ftp_session = 0
      end
    end
    if ftp_session != 0
      begin
        if $config["echi_ftp_directory"] != nil
          ftp_session.chdir($config["echi_ftp_directory"])
        end
        files = ftp_session.list('chr*')

        #Also fetch the *.dat files if it is configured to be processed
        if $config["echi_process_dat_files"] == "Y"
          files = files + ftp_session.list("*.dat")
        end
        #Build the queue of files to be fetched for the threads
        filequeue = Queue.new
        files.each do |file|
          file_data = file.split(' ')
          filequeue.push(file_data[8])
        end
        ftp_session.close
        return filequeue
      rescue => err
        log.info "Unable to fetch list from ftp server - " + err
        return nil
      end
    end
  end
  
  #Connect to the ftp server and fetch the files each time
  def fetch_ftp_files filequeue, log
    begin
      ftp_session = connect_ftp_session log
      if $config["echi_ftp_directory"] != nil
        ftp_session.chdir($config["echi_ftp_directory"])
      end
      while filequeue.empty? != true
        filename = filequeue.pop
        local_filename = $workingdir + '/../files/to_process/' + filename
        ftp_session.getbinaryfile(filename, local_filename)
        if $config["echi_ftp_delete"] == 'Y'
          ftp_session.delete(filename)
        end
      end
      ftp_session.close
      log.info "Closed ftp session."
      return true
    rescue => err
      log.info "Could not fetch from ftp server - " + err
      return false
    end
  end
  
end