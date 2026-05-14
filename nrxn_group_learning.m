function [plot_data_WT, plot_data_labels_WT, plot_data_KO, plot_data_labels_KO] = nrxn_group_learning(data_struct_WT, data_struct_KO, var_of_interest, fignum)

    % Analysis function for each animal learning by plotting a var of interest

    animalIDs_full_WT = unique({data_struct_WT.animalID}.');
    output_table_full_WT = struct2table(data_struct_WT);
    animal_ind_full_WT = findgroups(output_table_full_WT.animalID);

    animalIDs_full_KO = unique({data_struct_KO.animalID}.');
    output_table_full_KO = struct2table(data_struct_KO);
    animal_ind_full_KO = findgroups(output_table_full_KO.animalID);


    for a = 1:size(animalIDs_full_WT, 1)
        
        this_animal_ind = find(animal_ind_full_WT == a);
        this_animal_data = data_struct_WT(this_animal_ind);


            figure(fignum)
            hold on
            
            for i = 1:size(this_animal_data, 2)

                this_animal_data_plot(i, 1) = i - 1;
                this_animal_data_plot(i, 2) = eval(strcat('this_animal_data(i).', var_of_interest));
                

            end

                hold on
                plot(this_animal_data_plot(:, 2), '--', "Color", [.7 .7 .7])


            plot_data_cell_WT{1, a} = this_animal_data_plot(:, 2);
            plot_data_sizes_WT(1, a) = size(this_animal_data_plot(:, 2), 1);
            plot_data_labels_WT{:, a} = animalIDs_full_WT{a, :};

        clear this_animal_ind
        clear this_animal_data
        clear this_animal_target_learning_ind
        clear this_animal_data_plot

    end


    for a = 1:size(animalIDs_full_KO, 1)
        
        this_animal_ind = find(animal_ind_full_KO == a);
        this_animal_data = data_struct_KO(this_animal_ind);


            figure(fignum)
            hold on
            
            for i = 1:size(this_animal_data, 2)

                this_animal_data_plot(i, 1) = i - 1;
                this_animal_data_plot(i, 2) = eval(strcat('this_animal_data(i).', var_of_interest));
                

            end

                hold on
                plot(this_animal_data_plot(:, 2), '--', "Color", [0.9569 0.5 0.5])


            plot_data_cell_KO{1, a} = this_animal_data_plot(:, 2);
            plot_data_sizes_KO(1, a) = size(this_animal_data_plot(:, 2), 1);
            plot_data_labels_KO{:, a} = animalIDs_full_KO{a, :};

        clear this_animal_ind
        clear this_animal_data
        clear this_animal_target_learning_ind
        clear this_animal_data_plot

    end

max_plot_data_sizes_WT = max(plot_data_sizes_WT);

    for a = 1:size(plot_data_cell_WT, 2)

        if plot_data_sizes_WT(1, a) < max_plot_data_sizes_WT
            plot_data_WT(1:max_plot_data_sizes_WT, a) = NaN;
            plot_data_WT(1:plot_data_sizes_WT(1, a), a) = plot_data_cell_WT{1, a};
        else
            plot_data_WT(:, a) = plot_data_cell_WT{1, a};
        end

    end

max_plot_data_sizes_KO = max(plot_data_sizes_KO);

    for a = 1:size(plot_data_cell_KO, 2)

        if plot_data_sizes_KO(1, a) < max_plot_data_sizes_KO
            plot_data_KO(1:max_plot_data_sizes_KO, a) = NaN;
            plot_data_KO(1:plot_data_sizes_KO(1, a), a) = plot_data_cell_KO{1, a};
        else
            plot_data_KO(:, a) = plot_data_cell_KO{1, a};
        end

    end

end