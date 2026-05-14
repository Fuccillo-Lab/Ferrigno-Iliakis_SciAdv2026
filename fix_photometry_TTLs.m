function photometryStruct = fix_photometry_TTLs(behavior_TTLs, ttl_filename, box_number)

%%%%%%% Fixes TTL issues %%%%%%%%

% Maximum allowable difference between intervals
interval_tolerance = 0.0045; % Adjust based on expected jitter in seconds

% Import TTL data 
    data_TTL = importdata(ttl_filename);

    raw_TTLs = [str2num(cell2mat(data_TTL.textdata(:, 2))), data_TTL.data];

    if box_number == 1
        photometryStruct.original_TTLs_box1 = raw_TTLs(find(raw_TTLs(:,1) == 0), :);
        photometry_TTLs = photometryStruct.original_TTLs_box1;
    elseif box_number == 4
        photometryStruct.original_TTLs_box4 = raw_TTLs(find(raw_TTLs(:,1) == 1), :);
        photometry_TTLs = photometryStruct.original_TTLs_box4;
    end

photometry_TTLs_system = photometry_TTLs(:, 2); % System timestamps from TTLs_box1
photometry_TTLs_computer = photometry_TTLs(:, 3); % Computer timestamps from TTLs_box1

% Calculate the time differences (intervals) for each list
behavior_intervals = diff(behavior_TTLs);
behavior_intervals_sec = behavior_intervals ./ 1000000;
photometry_intervals = diff(photometry_TTLs_system);


photo_int = photometry_intervals;
previous_ttl_innacurate = false;
short_TTLs = false;
first_dropped = false;

for i = 1:size(behavior_intervals_sec, 1)

    if i == size(behavior_intervals_sec, 1) & size(behavior_intervals_sec, 1) > size(photo_int, 1) % if last TTL is missing from photometry file
        photo_int = [photo_int(1:i-1, 1); 0];

        photo_error(i, 1) = 1;
        photo_error(i, 3) = photo_int(i, 1);

        photo_int(i, 1) = behavior_intervals_sec(i, 1);

        photo_error(i, 2) = 1;
        photo_error(i, 5) = photo_int(i, 1);
        photo_error(i, 6) = 0;   
        continue;

    end

    if size(photo_int, 1) >= i 
	    if abs(behavior_intervals_sec(i, 1) - photo_int(i, 1)) < interval_tolerance
	        photo_error(i, 1) = 0;
	        photo_error(i, 2) = 0;
	    else
	        photo_error(i, 1) = 1;

	        % Check to see if this is just an inaccurate TTL rather than a dropped or bonus TTL (if so its worse to fix it)
	        if i < (size(photo_int, 1) - 2) 
	            if abs(abs(behavior_intervals_sec(i, 1) - photo_int(i, 1)) - abs(behavior_intervals_sec((i + 1), 1) - photo_int((i + 1), 1))) < (interval_tolerance / 2)
		            photo_error(i, 1) = 0;
	                photo_error(i, 2) = 0;
	                previous_ttl_innacurate = true;
	                continue
	            elseif previous_ttl_innacurate == true
		            photo_error(i, 1) = 0;
	                photo_error(i, 2) = 0;
	                previous_ttl_innacurate = false;
	                continue
	            end
	        end

	        % If this is the first TTL just make sure it isn't missing
	        if i == 1 & abs(photo_int(i, 1) - (behavior_intervals_sec(i+1, 1))) < interval_tolerance 

	            photo_int = [0; photo_int];

	            photo_int(i, 1) = behavior_intervals_sec(i, 1);
	            photo_error(i, 2) = 1;
	            photo_error(i, 5) = photo_int(i, 1);
                first_dropped = true;

	        elseif behavior_intervals_sec(i, 1) > photo_int(i, 1) & i < size(behavior_intervals_sec, 1) 
	            photo_error(i, 3) = photo_int(i, 1);
	            photo_error(i, 4) = photo_int((i + 1), 1);

	            photo_int(i, 1) = photo_int(i, 1) + photo_int((i + 1), 1);
	            photo_int = [photo_int(1:i, 1); photo_int((i+2):end, 1)];
	            photo_error(i, 2) = -1;
	            photo_error(i, 5) = photo_int(i, 1); % corrected interval (bonus TTL aggregated)

	        elseif i < (size(behavior_intervals_sec, 1)) & behavior_intervals_sec(i, 1) < photo_int(i, 1)

	            if abs(photo_int(i, 1) - (behavior_intervals_sec(i, 1) + behavior_intervals_sec(i+1, 1))) < interval_tolerance % if just one TTL was dropped
	                photo_error(i, 3) = photo_int(i, 1);
	    
	                photo_int = [photo_int(1:i, 1); 0; photo_int((i+1):end, 1)];
	                photo_int(i+1, 1) = behavior_intervals_sec(i+1, 1);
	                photo_int(i, 1) = abs(photo_int(i+1, 1) - photo_int(i, 1));
	                photo_error(i, 2) = 1;
	                photo_error(i, 5) = photo_int(i, 1);
	                photo_error(i, 6) = photo_int(i+1, 1);
	            elseif abs(photo_int(i, 1) - (behavior_intervals_sec(i, 1) + behavior_intervals_sec(i+1, 1) + behavior_intervals_sec(i+2, 1))) < interval_tolerance % if two TTLs were dropped
	                photo_error(i, 3) = photo_int(i, 1);

	                photo_int = [photo_int(1:i, 1); 0; 0; photo_int((i+1):end, 1)];
	                photo_int(i+2, 1) = behavior_intervals_sec(i+2, 1);
	                photo_int(i+1, 1) = behavior_intervals_sec(i+1, 1);
	                photo_int(i, 1) = abs((photo_int(i+2, 1) + photo_int(i+1, 1)) - photo_int(i, 1));
	                photo_error(i, 2) = 2;
	                photo_error(i, 5) = photo_int(i, 1);
	                photo_error(i, 6) = photo_int(i+1, 1);
	                photo_error(i, 7) = photo_int(i+2, 1);
	            elseif abs(photo_int(i, 1) - (behavior_intervals_sec(i, 1) + behavior_intervals_sec(i+1, 1) + behavior_intervals_sec(i+2, 1) + behavior_intervals_sec(i+3, 1))) < interval_tolerance % if three TTLs were dropped
	                photo_error(i, 3) = photo_int(i, 1);

	                photo_int = [photo_int(1:i, 1); 0; 0; 0; photo_int((i+1):end, 1)];
	                photo_int(i+3, 1) = behavior_intervals_sec(i+3, 1);
	                photo_int(i+2, 1) = behavior_intervals_sec(i+2, 1);
	                photo_int(i+1, 1) = behavior_intervals_sec(i+1, 1);
	                photo_int(i, 1) = abs((photo_int(i+3, 1) + photo_int(i+2, 1) + photo_int(i+1, 1)) - photo_int(i, 1));
	                photo_error(i, 2) = 3;
	                photo_error(i, 5) = photo_int(i, 1);
	                photo_error(i, 6) = photo_int(i+1, 1);
	                photo_error(i, 7) = photo_int(i+2, 1);
	                photo_error(i, 8) = photo_int(i+3, 1);

	            end

            elseif i == (size(behavior_intervals_sec, 1)) & behavior_intervals_sec(i, 1) < photo_int(i, 1) % if last TTL is dropped
	            photo_error(i, 3) = photo_int(i, 1);

	            photo_int(i, 1) = behavior_intervals_sec(i, 1);

	            photo_error(i, 2) = 1;
	            photo_error(i, 5) = photo_int(i, 1);
	            photo_error(i, 6) = 0;   

            elseif i == (size(behavior_intervals_sec, 1)) & behavior_intervals_sec(i, 1) > photo_int(i, 1) % if theres a bonus TTL at the end
	            photo_error(i, 3) = photo_int(i, 1);
	            photo_error(i, 4) = photo_int((i + 1), 1);

	            photo_int(i, 1) = photo_int(i, 1) + photo_int((i + 1), 1);
	            photo_int = [photo_int(1:i, 1); photo_int((i+2):end, 1)];
	            photo_error(i, 2) = -1;
	            photo_error(i, 5) = photo_int(i, 1); % corrected interval (bonus TTL aggregated)

	        end
	    end
    else
        short_TTLs = true;
	 	break
	 end    
end

photo_error_ind = find(photo_error(:, 1) == 1);

for i = 1:size(photo_error_ind, 1)

    if photo_error_ind(i, 1) == 1 & photo_error(photo_error_ind(i, 1), 2) == 1 & first_dropped == true % if the first TTL was missed
        TTL_fix_index(i, 1) = 1;

        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);
        TTL_fix_index(i, 5) = photo_error(photo_error_ind(i, 1), 6);
    elseif photo_error_ind(i, 1) == 1 & photo_error(photo_error_ind(i, 1), 2) == 1 & first_dropped == false
        TTL_fix_index(i, 1) = 1;
        TTL_fix_index(i, 2) = 1;
        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);
        TTL_fix_index(i, 5) = photo_error(photo_error_ind(i, 1), 6);
    elseif photo_error(photo_error_ind(i, 1), 2) == 1 & photo_error_ind(i, 1) < size(photo_error, 1) & photo_error_ind(i, 1) > 1
        TTL_fix_index(i, 1) = 1;

        if size(find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3)), 1) == 1
            TTL_fix_index(i, 2) = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
        else
            display('Duplicate intervals found for TTL intervals.')
            multiple_matches = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
            TTL_fix_index(i, 2) = multiple_matches(knnsearch(multiple_matches,photo_error_ind(i, 1)), 1);
        end

        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);
        TTL_fix_index(i, 5) = photo_error(photo_error_ind(i, 1), 6);

    elseif photo_error(photo_error_ind(i, 1), 2) == 1 & photo_error_ind(i, 1) == size(photo_error, 1) % if last ttl was dropped
        TTL_fix_index(i, 1) = 1;
        TTL_fix_index(i, 2) = size(photometry_intervals, 1);

        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);
        TTL_fix_index(i, 5) = photo_error(photo_error_ind(i, 1), 6);

    elseif photo_error(photo_error_ind(i, 1), 2) == 2
        TTL_fix_index(i, 1) = 2;

        if size(find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3)), 1) == 1
            TTL_fix_index(i, 2) = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
        else
            display('Duplicate intervals found for TTL intervals.')
            multiple_matches = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
            TTL_fix_index(i, 2) = multiple_matches(knnsearch(multiple_matches,photo_error_ind(i, 1)), 1);
        end

        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);
        TTL_fix_index(i, 5) = photo_error(photo_error_ind(i, 1), 6);
        TTL_fix_index(i, 6) = photo_error(photo_error_ind(i, 1), 7);

    elseif photo_error(photo_error_ind(i, 1), 2) == 3
        TTL_fix_index(i, 1) = 3;

        if size(find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3)), 1) == 1
            TTL_fix_index(i, 2) = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
        else
            display('Duplicate intervals found for TTL intervals.')
            multiple_matches = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
            TTL_fix_index(i, 2) = multiple_matches(knnsearch(multiple_matches,photo_error_ind(i, 1)), 1);
        end

        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);
        TTL_fix_index(i, 5) = photo_error(photo_error_ind(i, 1), 6);
        TTL_fix_index(i, 6) = photo_error(photo_error_ind(i, 1), 7);
        TTL_fix_index(i, 7) = photo_error(photo_error_ind(i, 1), 8);

    elseif photo_error(photo_error_ind(i, 1), 2) == -1
        TTL_fix_index(i, 1) = -1;
        
        if size(find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3)), 1) == 1
            TTL_fix_index(i, 2) = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
        else
            display('Duplicate intervals found for TTL intervals.')
            multiple_matches = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 3));
            TTL_fix_index(i, 2) = multiple_matches(knnsearch(multiple_matches,photo_error_ind(i, 1)), 1);
        end

        TTL_fix_index(i, 3) = find(photometry_intervals == photo_error(photo_error_ind(i, 1), 4));
        TTL_fix_index(i, 4) = photo_error(photo_error_ind(i, 1), 5);

    end

end

if exist("TTL_fix_index")

    initial_errors = TTL_fix_index;
    
    for i = 1:size(TTL_fix_index, 1)

        if TTL_fix_index(i, 1) == 1 & TTL_fix_index(i, 2) == 0 & first_dropped == true % if first TTL was missed
            photometry_TTLs_system = [0; photometry_TTLs_system];
            photometry_TTLs_system(1, 1) = photometry_TTLs_system(2, 1) - TTL_fix_index(i, 4);
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) + 1;
        elseif TTL_fix_index(i, 1) == 1 & TTL_fix_index(i, 2) == 1 & first_dropped == false % if second TTL was missed
            photometry_TTLs_system = [0; photometry_TTLs_system];
            photometry_TTLs_system(1, 1) = photometry_TTLs_system(2, 1);
            photometry_TTLs_system(2, 1) = photometry_TTLs_system(2, 1) - TTL_fix_index(i, 4);
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) + 1;
        elseif TTL_fix_index(i, 1) == 1 & TTL_fix_index(i, 2) > 0 & TTL_fix_index(i, 5) == 0 % if last TTL was dropped
            photometry_TTLs_system = [photometry_TTLs_system(1:end, 1); (photometry_TTLs_system(end, 1) + TTL_fix_index(i, 4))];
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) + 1;        
        elseif TTL_fix_index(i, 1) == 1 & TTL_fix_index(i, 2) > 0
            photometry_TTLs_system = [photometry_TTLs_system(1:TTL_fix_index(i, 2), 1); (photometry_TTLs_system(TTL_fix_index(i, 2), 1) + TTL_fix_index(i, 4)); photometry_TTLs_system((TTL_fix_index(i, 2) + 1):end, 1)];
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) + 1;
        elseif TTL_fix_index(i, 1) == -1
            photometry_TTLs_system = [photometry_TTLs_system(1:TTL_fix_index(i, 2), 1); photometry_TTLs_system((TTL_fix_index(i, 2) + 2):end, 1)];
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) - 1;
        elseif TTL_fix_index(i, 1) == 2
            photometry_TTLs_system = [photometry_TTLs_system(1:TTL_fix_index(i, 2), 1); (photometry_TTLs_system(TTL_fix_index(i, 2), 1) + TTL_fix_index(i, 4)); photometry_TTLs_system((TTL_fix_index(i, 2) + 1):end, 1)];
            photometry_TTLs_system = [photometry_TTLs_system(1:(TTL_fix_index(i, 2) + 1), 1); (photometry_TTLs_system(TTL_fix_index(i, 2) + 1, 1) + TTL_fix_index(i, 5)); photometry_TTLs_system((TTL_fix_index(i, 2) + 2):end, 1)];
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) + 2;       
        elseif TTL_fix_index(i, 1) == 3
            photometry_TTLs_system = [photometry_TTLs_system(1:TTL_fix_index(i, 2), 1); (photometry_TTLs_system(TTL_fix_index(i, 2), 1) + TTL_fix_index(i, 4)); photometry_TTLs_system((TTL_fix_index(i, 2) + 1):end, 1)];            
            photometry_TTLs_system = [photometry_TTLs_system(1:(TTL_fix_index(i, 2) + 1), 1); (photometry_TTLs_system(TTL_fix_index(i, 2) + 1, 1) + TTL_fix_index(i, 5)); photometry_TTLs_system((TTL_fix_index(i, 2) + 2):end, 1)];
            photometry_TTLs_system = [photometry_TTLs_system(1:(TTL_fix_index(i, 2) + 2), 1); (photometry_TTLs_system(TTL_fix_index(i, 2) + 2, 1) + TTL_fix_index(i, 6)); photometry_TTLs_system((TTL_fix_index(i, 2) + 3):end, 1)];
            TTL_fix_index(i+1:end, 2) = TTL_fix_index(i+1:end, 2) + 3;   
        end
    
    end
    
    photometry_intervals_test = diff(photometry_TTLs_system);
    clear photo_error
    clear photo_int
    
    photo_int = photometry_intervals_test;
 for i = 1:size(behavior_intervals_sec, 1)
    

    if i == size(behavior_intervals_sec, 1) & size(behavior_intervals_sec, 1) > size(photo_int, 1) % if last TTL is missing from photometry file
        photo_int = [photo_int(1:i-1, 1); 0];

        photo_error(i, 1) = 1;
        photo_error(i, 3) = photo_int(i, 1);

        photo_int(i, 1) = behavior_intervals_sec(i, 1);

        photo_error(i, 2) = 1;
        photo_error(i, 5) = photo_int(i, 1);
        photo_error(i, 6) = 0;   
        continue;

    end

    if size(photo_int, 1) >= i 
	    if abs(behavior_intervals_sec(i, 1) - photo_int(i, 1)) < interval_tolerance
	        photo_error(i, 1) = 0;
	        photo_error(i, 2) = 0;
	    else
	        photo_error(i, 1) = 1;

	        % Check to see if this is just an inaccurate TTL rather than a dropped or bonus TTL (if so its worse to fix it)
	        if i < (size(photo_int, 1) - 2) 
	            if abs(abs(behavior_intervals_sec(i, 1) - photo_int(i, 1)) - abs(behavior_intervals_sec((i + 1), 1) - photo_int((i + 1), 1))) < interval_tolerance
		            photo_error(i, 1) = 0;
	                photo_error(i, 2) = 0;
	                previous_ttl_innacurate = true;
	                continue
	            elseif previous_ttl_innacurate == true
		            photo_error(i, 1) = 0;
	                photo_error(i, 2) = 0;
	                previous_ttl_innacurate = false;
	                continue
	            end
	        end

	        % If this is the first TTL just make sure it isn't missing
	        if i == 1 & abs(photo_int(i, 1) - (behavior_intervals_sec(i+1, 1))) < interval_tolerance 

	            photo_int = [0; photo_int];

	            photo_int(i, 1) = behavior_intervals_sec(i, 1);
	            photo_error(i, 2) = 1;
	            photo_error(i, 5) = photo_int(i, 1);

	        elseif behavior_intervals_sec(i, 1) > photo_int(i, 1) & i < size(behavior_intervals_sec, 1) 
	            photo_error(i, 3) = photo_int(i, 1);
	            photo_error(i, 4) = photo_int((i + 1), 1);

	            photo_int(i, 1) = photo_int(i, 1) + photo_int((i + 1), 1);
	            photo_int = [photo_int(1:i, 1); photo_int((i+2):end, 1)];
	            photo_error(i, 2) = -1;
	            photo_error(i, 5) = photo_int(i, 1); % corrected interval (bonus TTL aggregated)

	        elseif i < (size(behavior_intervals_sec, 1)) & behavior_intervals_sec(i, 1) < photo_int(i, 1)

	            if abs(photo_int(i, 1) - (behavior_intervals_sec(i, 1) + behavior_intervals_sec(i+1, 1))) < interval_tolerance % if just one TTL was dropped
	                photo_error(i, 3) = photo_int(i, 1);
	    
	                photo_int = [photo_int(1:i, 1); 0; photo_int((i+1):end, 1)];
	                photo_int(i+1, 1) = behavior_intervals_sec(i+1, 1);
	                photo_int(i, 1) = abs(photo_int(i+1, 1) - photo_int(i, 1));
	                photo_error(i, 2) = 1;
	                photo_error(i, 5) = photo_int(i, 1);
	                photo_error(i, 6) = photo_int(i+1, 1);
	            elseif abs(photo_int(i, 1) - (behavior_intervals_sec(i, 1) + behavior_intervals_sec(i+1, 1) + behavior_intervals_sec(i+2, 1))) < interval_tolerance % if two TTLs were dropped
	                photo_error(i, 3) = photo_int(i, 1);

	                photo_int = [photo_int(1:i, 1); 0; 0; photo_int((i+1):end, 1)];
	                photo_int(i+2, 1) = behavior_intervals_sec(i+2, 1);
	                photo_int(i+1, 1) = behavior_intervals_sec(i+1, 1);
	                photo_int(i, 1) = abs((photo_int(i+2, 1) + photo_int(i+1, 1)) - photo_int(i, 1));
	                photo_error(i, 2) = 2;
	                photo_error(i, 5) = photo_int(i, 1);
	                photo_error(i, 6) = photo_int(i+1, 1);
	                photo_error(i, 7) = photo_int(i+2, 1);
	            elseif abs(photo_int(i, 1) - (behavior_intervals_sec(i, 1) + behavior_intervals_sec(i+1, 1) + behavior_intervals_sec(i+2, 1) + behavior_intervals_sec(i+3, 1))) < interval_tolerance % if three TTLs were dropped
	                photo_error(i, 3) = photo_int(i, 1);

	                photo_int = [photo_int(1:i, 1); 0; 0; 0; photo_int((i+1):end, 1)];
	                photo_int(i+3, 1) = behavior_intervals_sec(i+3, 1);
	                photo_int(i+2, 1) = behavior_intervals_sec(i+2, 1);
	                photo_int(i+1, 1) = behavior_intervals_sec(i+1, 1);
	                photo_int(i, 1) = abs((photo_int(i+3, 1) + photo_int(i+2, 1) + photo_int(i+1, 1)) - photo_int(i, 1));
	                photo_error(i, 2) = 3;
	                photo_error(i, 5) = photo_int(i, 1);
	                photo_error(i, 6) = photo_int(i+1, 1);
	                photo_error(i, 7) = photo_int(i+2, 1);
	                photo_error(i, 8) = photo_int(i+3, 1);

	            end

	        elseif i == (size(behavior_intervals_sec, 1)) & behavior_intervals_sec(i, 1) < photo_int(i, 1)
	            photo_error(i, 3) = photo_int(i, 1);

	            photo_int(i, 1) = behavior_intervals_sec(i, 1);

	            photo_error(i, 2) = 1;
	            photo_error(i, 5) = photo_int(i, 1);
	            photo_error(i, 6) = 0;    

	        end
	    end
    else
        short_TTLs = true;
	 	break
    end

    end
    
    pervasive_errors = find(photo_error(:, 1) == 1);
    
        if box_number == 1 & short_TTLs == false
            photometryStruct.final_photoTTLs_box1 = photometry_TTLs_system(1:size(behavior_TTLs, 1), 1);
            photometryStruct.initial_photoTTL_errors_box1 = initial_errors;
            photometryStruct.pervasive_photoTTL_errors_box1 = pervasive_errors;
            photometryStruct.short_TTLs_box1 = short_TTLs;
        elseif box_number == 4 & short_TTLs == false
            photometryStruct.final_photoTTLs_box4 = photometry_TTLs_system(1:size(behavior_TTLs, 1), 1);
            photometryStruct.initial_photoTTL_errors_box4 = initial_errors;
            photometryStruct.pervasive_photoTTL_errors_box4 = pervasive_errors;
            photometryStruct.short_TTLs_box4 = short_TTLs;
        elseif box_number == 1 & short_TTLs == true
            photometryStruct.final_photoTTLs_box1 = photometry_TTLs_system;
            photometryStruct.initial_photoTTL_errors_box1 = initial_errors;
            photometryStruct.pervasive_photoTTL_errors_box1 = pervasive_errors;
            photometryStruct.short_TTLs_box1 = short_TTLs;            
        elseif box_number == 4 & short_TTLs == true
            photometryStruct.final_photoTTLs_box4 = photometry_TTLs_system;
            photometryStruct.initial_photoTTL_errors_box4 = initial_errors;
            photometryStruct.pervasive_photoTTL_errors_box4 = pervasive_errors;
            photometryStruct.short_TTLs_box4 = short_TTLs;
        end
else % if there are no TTL errors in file!!
    
        if box_number == 1
            photometryStruct.final_photoTTLs_box1 = photometry_TTLs_system(1:size(behavior_TTLs, 1), 1);
            photometryStruct.initial_photoTTL_errors_box1 = [];
            photometryStruct.pervasive_photoTTL_errors_box1 = [];
            photometryStruct.short_TTLs_box1 = [];
        elseif box_number == 4
            photometryStruct.final_photoTTLs_box4 = photometry_TTLs_system(1:size(behavior_TTLs, 1), 1);
            photometryStruct.initial_photoTTL_errors_box4 = [];
            photometryStruct.pervasive_photoTTL_errors_box4 = [];
            photometryStruct.short_TTLs_box4 = [];
        end    

end

end