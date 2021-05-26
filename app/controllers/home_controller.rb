class HomeController < ApplicationController


	def index
	end

	def convert
	    rowarray = Array.new
	    

	    myfile = params[:convert][:file]

	  #  outputFile = Tempfile.new([ 'foobar', '.xlsx' ])

	  output = ""


	     File.open(myfile, "r").each_line do |line|
	        Rails.logger.info line
	        if (line.start_with?("A")) 
	        	line = "A104Merge Meet Results       Hy-Tek, Ltd    MM5 7.0Gb     05252021  3:32 PMOlentangy Swim Association Swim Team                 82\r\n"
	        end
	        if (line.start_with?("E2F")) 
	        	columns = line.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")
	        	if (columns.size > 1)
	        		time =  columns[1]
	        		if (time[time.length-1] == 'Y')
	        			timeRaw = time.chomp("Y")
	        			timeFloat = timeRaw.to_f
	        			newTime = timeFloat * 1.10999215
	        			newTimeStr = newTime.round(2).to_s
	        			line.gsub!(time, newTimeStr+"Y")
	        			  Rails.logger.info line
	      
	        		end

	        	end
	        end
	        output = output + line

	     end
	     #outputFile.close
	    #send_file(outputFile.path)
	     # remove the file from /tmp
		#outputFile	.unlink


		send_data output,
    	:type => 'text/text; charset=UTF-8;',
    	:disposition => "attachment; filename=Merge Meet Results-VirtualMeet-05June2021-007.hy3"

	end
   
end
