class HomeController < ApplicationController


	def index
	end

	def convert
	    
	    file1 = params[:convert][:file]
	    file2 = params[:convert][:file2]
	    file3 = params[:convert][:file3]
	    file4 = params[:convert][:file4]
	    file5 = params[:convert][:file5]
	    file6 = params[:convert][:file6]
	    file7 = params[:convert][:file7]
	    file8 = params[:convert][:file8]
	    file9 = params[:convert][:file9]
	    meetName = params[:convert][:meet_name]
	    meetDate = params[:convert][:meet_date]

	   	output = "A104Merge Meet Results       Hy-Tek, Ltd    MM5 7.0Gb     05252021  3:32 PMOlentangy Swim Association Swim Team                 82\r\n"
	   	output += "B1Virtual Meet                                 Olentangy Swim Association                   060520210605202106152021   0        41\r\n"
	   	output += "B2                                                                                          010101Y1  0.00                      61\r\n"

	   	eventResults = Hash.new
	   	eventResults = append_to_results_hash(file1, eventResults)
	   	if (file2)
	   		eventResults = append_to_results_hash(file2, eventResults)
	   	end

	   	if (file3)
	   		eventResults = append_to_results_hash(file3, eventResults)
	   	end

	   	if (file4)
	   		eventResults = append_to_results_hash(file4, eventResults)
	   	end

	   	if (file5)
	   		eventResults = append_to_results_hash(file5, eventResults)
	   	end

	   	if (file6)
	   		eventResults = append_to_results_hash(file6, eventResults)
	   	end

	   	if (file7)
	   		eventResults = append_to_results_hash(file7, eventResults)
	   	end

	   	if (file8)
	   		eventResults = append_to_results_hash(file8, eventResults)
	   	end

	   	if (file9)
	   		eventResults = append_to_results_hash(file9, eventResults)
	   	end
	  	
	   	output += to_hy3(eventResults)
	    
		send_data output,
    	:type => 'text/text; charset=UTF-8;',
    	:disposition => "attachment; filename=Merge Meet Results-#{meetName}-#{meetDate}-001.hy3"

	end


	def append_to_results_hash( fileName, eventResults)

		eventResultStr = "";
		lastEvent = "";
		preEventNumLines = "";
		File.open(fileName, "r").each_line do |line|
	        Rails.logger.info "Incoming: " + line
	        if (!line.start_with?("A") && !line.start_with?("B")) 

	        	#these lines appear before the event number so we will save them once we figure out which event we are on
	        	if (line.start_with?("C") || line.start_with?("D")) 
	        		preEventNumLines = preEventNumLines + line
	        	else 

		        	if (line.start_with?("E1"))
		        		afterSwimmer = line[18..]
			        	columns = afterSwimmer.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")

			        	if (columns.size >  6)
			        		eventNum = columns[5]
			        		if eventNum != lastEvent 
			        			if !eventResultStr.empty? && ! lastEvent.empty? 
			        				eventResults[lastEvent] = (eventResults[lastEvent] == nil ?  "" : eventResults[lastEvent] ) + eventResultStr
			        				Rails.logger.info "Saved: " + eventResults[lastEvent] + " for event " + lastEvent

			        				
			     	  			end
			        			eventResultStr = preEventNumLines;
			        			lastEvent = eventNum
			        		else 
			        			eventResultStr = eventResultStr + preEventNumLines

			        		end
			        		Rails.logger.info "Adding: " + line
			        		eventResultStr = eventResultStr + line
			        	end
			        	preEventNumLines = ""  
			        end

			        if (line.start_with?("E2"))

			        	columns = line.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")
			        	if (columns.size > 4)
			        		time =  columns[1]
			        		if (time[time.length-1] == 'Y')
			        			timeRaw = time.chomp("Y")
			        			timeFloat = timeRaw.to_f
			        			newTime = timeFloat * 1.10999215
			        			newTimeStr = newTime.round(2).to_s
			        			line.gsub!(time, newTimeStr+"S")
			        			checksum = getHY3checksum(line.rstrip)
			        			line = line.rstrip[0..-3] + checksum + "\r\n"
			        			  
			      
			        		end

			        	end
			        	Rails.logger.info "Adding: " + line
			        	eventResultStr = eventResultStr + line
			        end

			        
			     end
		     end

	     end
	     eventResults[lastEvent] = (eventResults[lastEvent] == nil ?  "" : eventResults[lastEvent] ) + eventResultStr
	     Rails.logger.info "Saved: " + eventResults[lastEvent] + " for event " + lastEvent

	     return eventResults
	end 


	def to_hy3(eventResults)
		output = ""
		eventResults.each do |key, value|
			output = output + value
		end
		return output
	end


def getHY3checksum(data)
			        			
	even = 0
	odd = 0
	for i in  0..(data.length - 3) 
		if (i % 2 == 0) 
			even += data[i].ord; 
		else 
			odd += 2 * data[i].ord; 
		end
	end
	total = (even + odd); 
	floor = (total/21.0).floor; 
	add205 =  (floor + 205); 
	mod100 = add205 % 100; 
	d1 = mod100 % 10; 
	d2 = mod100 / 10; 
	return "#{d1}#{d2}"
end
   
end

