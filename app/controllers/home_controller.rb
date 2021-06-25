include ActionView::Helpers::NumberHelper

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
	   	eventHeats = Hash.new
	    eventLanes = Hash.new
	   	eventResults = append_to_results_hash(file1, eventResults, eventHeats, eventLanes, meetDate)
	   	if (file2)
	   		eventResults = append_to_results_hash(file2, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file3)
	   		eventResults = append_to_results_hash(file3, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file4)
	   		eventResults = append_to_results_hash(file4, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file5)
	   		eventResults = append_to_results_hash(file5, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file6)
	   		eventResults = append_to_results_hash(file6, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file7)
	   		eventResults = append_to_results_hash(file7, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file8)
	   		eventResults = append_to_results_hash(file8, eventResults, eventHeats, eventLanes, meetDate)
	   	end

	   	if (file9)
	   		eventResults = append_to_results_hash(file9, eventResults, eventHeats, eventLanes, meetDate)
	   	end
	  	
	   	output += to_hy3(eventResults)
	    
		send_data output,
    	:type => 'text/text; charset=UTF-8;',
    	:disposition => "attachment; filename=Merge Meet Results-#{meetName}-#{meetDate}-001.hy3"

	end


	def append_to_results_hash( fileName, eventResults, eventHeats, eventLanes, meetDate)


		eventResultStr = "";
		eventNum = 0;
		athleteLines = "";
		teamLine  = ""
		File.open(fileName, "r").each_line do |line|
	      #  Rails.logger.info "Incoming: " + line
	        if (!line.start_with?("A") && !line.start_with?("B") && !line.start_with?("C2") && !line.start_with?("C3")) 

	        	#these lines appear before the event number so we will save them once we figure out which event we are on
	        	if (line.start_with?("C1") )
	        		teamLine = line
	        	elsif (line.start_with?("D1")) 
	        		athleteLines = line	
	        	elsif (line.start_with?("D")) 
	        		athleteLines = athleteLines + line		
	        	else 

		        	if (line.start_with?("E1") || line.start_with?("F1"))
		        		if line.start_with?("F1")
		        			athleteLines = ""
		        		end
		        		afterSwimmer = line[18..]
			        	columns = afterSwimmer.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")
			        	#Rails.logger.info("column size: #{columns.size} #{columns}" )
			        	#if (columns.size >  12)
			        	

			        	if columns.size < 11 
			        		eventNum = columns[3]
			        		line[30..37] = "0S  0.00"
			        		line[46..50] = "0.00S"
			        		line[55..59] = "0.00S"
			        		line[64..67] = "0.00"
			        		line[64..67] = "0.00"
			        		line[72..75] = "0.00"
			        		line[79..80] = "NN"
			        		line[96] = "N"
			        		checksum = getHY3checksum(line.rstrip)
			        		line = line.rstrip[0..-3] + checksum + "\r\n"
			        	else 
			        		eventNum = columns[5]
				        	if eventNum.to_s != eventNum.to_i.to_s
				        		eventNum = columns[4]
				        	end
			        	end
			        	#else  
			        	#	eventNum = columns[4]
			        	#end

						eventResultStr = teamLine + athleteLines + line			        		
			        end

			        if (line.start_with?("E2") || line.start_with?("F2"))
			        	prevLine = line.dup

			        	columns = line.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ")
			        	if (columns.size > 2)
			        		time =  columns[1]
			        		newTimeStr = time.to_s
			        		if (time[time.length-1] == 'Y')
			        			timeRaw = time.chomp("Y")
			        			timeFloat = timeRaw.to_f
			        			newTime = timeFloat * 1.10999215
			        			newTimeStr = number_with_precision(newTime, :precision => 2).to_str + "S"
								
								timeLen = newTimeStr.length 
								timeIndex = timeLen - 1
								startIndex = (11- timeLen) + 1
								for index in (11).downto(startIndex)
									line[index] = newTimeStr[timeIndex]
									timeIndex = timeIndex - 1
								end			        			
			        			  
			      
			        		end
			        		if !heat = eventHeats[eventNum] 
			        			heat = 1
			        		end
			        		if !lane = eventLanes[eventNum] 
			        			lane = 0
			        		end

			        		if lane == 8
			        			heat = heat + 1
			        			lane = 1
			        		else 
			        			lane = lane + 1
			        		end

			        		eventHeats[eventNum] = heat
			        		eventLanes[eventNum] = lane

			        		Rails.logger.info "event #{eventNum} was using heat #{line[22]} lane #{line[25]}"
			        		Rails.logger.info "event #{eventNum} is now using heat #{heat} lane #{lane}"
							

							

							line[22] = heat.to_s
							line[25] = lane.to_s
				
							if line[19] == " "
								line[19] = "0"
							end
 
							if line[28] == " " || line[28] == "0"
								line[28] = "1"
							end

							if line[32] == " " || line[32] == "0"
								line[32] = "1"
							end

							if line[35] == " "
								line[35] = "0"
							end

							if columns.size < 6
								timeStrWithoutCourse = newTimeStr.tr('^0-9.', '')  
								timeLen = timeStrWithoutCourse.length 
								timeIndex = timeLen - 1
								startIndex = (43 - timeLen) + 1
								for index in (43).downto(startIndex)
									line[index] = timeStrWithoutCourse[timeIndex]
									timeIndex = timeIndex - 1
								end

								line[48..51] = "0.00"
								line[56..59] = "0.00"
								line[62] = ""
								line[69..72] = "0.00"
								line[78..81] = "0.00"

								date = DateTime.parse(meetDate)
								formatted_date = date.strftime('%m%d%Y')
								line[87..94] = formatted_date
								line[122] = "0 " 
								end 
							checksum = getHY3checksum(line.rstrip)
			        		line = line.rstrip[0..-3] + checksum + "\r\n"
			        		Rails.logger.info "event line length #{line.length}"
			        		if (line.length > 132) 
			        			Rails.logger.info "event line length #{line.length}"
			        		end

			



			        		

			        	end
			        	
			        	eventResultStr = eventResultStr + line
			        	if (line.start_with?("E2"))
			        	#	Rails.logger.info "Adding  for event " + eventNum + ": " + eventResultStr
			        		eventResults[eventNum] = (eventResults[eventNum] == nil ?  "" : eventResults[eventNum] ) + eventResultStr
			        		eventResultStr = ""

			        	end
			        end

			        if (line.start_with?("F3"))
			        	eventResultStr = eventResultStr + line
			        #		Rails.logger.info "Adding  for event " + eventNum + ": " + eventResultStr
			         		eventResults[eventNum] = (eventResults[eventNum] == nil ?  "" : eventResults[eventNum] ) + eventResultStr
			        		eventResultStr = ""
			         end

			        
			     end
		     end

	     end
	    
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

