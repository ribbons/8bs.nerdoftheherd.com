module EBS
  class Menu
    def initialize(disc)
      data = disc.file('$.!BOOT')

      line = read_data_line(data)
      @issue_date = line.split(',')[1]
    end

    attr_reader :issue_date

    def read_data_line(data)
      loop do
        fail 'Malformed BBC BASIC file' if data.readbyte != 0x0d

        # End of file marker
        return nil if data.readbyte == 0xff

        # Skip second byte of line number
        data.readbyte

        # Entire length of line, so subtract bytes already read
        linelen = data.readbyte - 4

        # Only a valid data line if first byte is the DATA token
        is_data_line = data.readbyte == 0xdc

        if is_data_line
          line = ''

          (linelen - 1).times do
            line += data.readbyte.chr
          end

          return line.strip
        end

        # Read and discard the rest of the line
        (linelen - 1).times { data.readbyte }
      end
    end
  end
end
