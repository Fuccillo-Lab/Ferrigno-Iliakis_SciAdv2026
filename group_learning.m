function [plot_data, plot_data_labels] = group_learning(data_struct, var_of_interest, fignum, color)

    % Analysis function for each animal learning by plotting a var of interest

    animalIDs_full = unique({data_struct.animalID}.');
    output_table_full = struct2table(data_struct);
    animal_ind_full = findgroups(output_table_full.animalID);

    for a = 1:size(animalIDs_full, 1)
        
        this_animal_ind = find(animal_ind_full == a);
        this_animal_data = data_struct(this_animal_ind);


            figure(fignum)
            hold on
            
            for i = 1:size(this_animal_data, 2)

                this_animal_data_plot(i, 1) = i - 1;

                try
                this_animal_data_plot(i, 2) = eval(strcat('this_animal_data(i).', var_of_interest));
                catch
                this_animal_data_plot(i, 2) = NaN;
                end
              

            end
                if color == 1
                    hold on
                    plot(this_animal_data_plot(:, 2), '--')
                else 
                    hold on
                    plot(this_animal_data_plot(:, 2), '--', 'color', [.6 .6 .6])
                end


            plot_data_cell{1, a} = this_animal_data_plot(:, 2);
            plot_data_sizes(1, a) = size(this_animal_data_plot(:, 2), 1);
            plot_data_labels{:, a} = animalIDs_full{a, :};

        clear this_animal_ind
        clear this_animal_data
        clear this_animal_target_learning_ind
        clear this_animal_data_plot

    end

legend(animalIDs_full)

max_plot_data_sizes = max(plot_data_sizes);

    for a = 1:size(animalIDs_full, 1)

        if plot_data_sizes(1, a) < max_plot_data_sizes
            plot_data(1:max_plot_data_sizes, a) = NaN;
            plot_data(1:plot_data_sizes(1, a), a) = plot_data_cell{1, a};
        else
            plot_data(:, a) = plot_data_cell{1, a};
        end

    end

end