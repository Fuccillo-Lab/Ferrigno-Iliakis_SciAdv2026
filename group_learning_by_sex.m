function [plot_data_mal, plot_data_labels_mal, plot_data_fem, plot_data_labels_fem] = group_learning_by_sex(data_struct_mal, data_struct_fem, var_of_interest, fignum)

    % Analysis function for each animal learning by plotting a var of interest

    animalIDs_full_mal = unique({data_struct_mal.animalID}.');
    output_table_full_mal = struct2table(data_struct_mal);
    animal_ind_full_mal = findgroups(output_table_full_mal.animalID);

    animalIDs_full_fem = unique({data_struct_fem.animalID}.');
    output_table_full_fem = struct2table(data_struct_fem);
    animal_ind_full_fem = findgroups(output_table_full_fem.animalID);


    for a = 1:size(animalIDs_full_mal, 1)
        
        this_animal_ind = find(animal_ind_full_mal == a);
        this_animal_data = data_struct_mal(this_animal_ind);


            figure(fignum)
            hold on
            
            for i = 1:size(this_animal_data, 2)

                this_animal_data_plot(i, 1) = i - 1;
                this_animal_data_plot(i, 2) = eval(strcat('this_animal_data(i).', var_of_interest));
                

            end

                hold on
                plot(this_animal_data_plot(:, 2), '--', "Color", [.2 .6 1]) % Light blue


            plot_data_cell_mal{1, a} = this_animal_data_plot(:, 2);
            plot_data_sizes_mal(1, a) = size(this_animal_data_plot(:, 2), 1);
            plot_data_labels_mal{:, a} = animalIDs_full_mal{a, :};

        clear this_animal_ind
        clear this_animal_data
        clear this_animal_target_learning_ind
        clear this_animal_data_plot

    end


    for a = 1:size(animalIDs_full_fem, 1)
        
        this_animal_ind = find(animal_ind_full_fem == a);
        this_animal_data = data_struct_fem(this_animal_ind);


            figure(fignum)
            hold on
            
            for i = 1:size(this_animal_data, 2)

                this_animal_data_plot(i, 1) = i - 1;
                this_animal_data_plot(i, 2) = eval(strcat('this_animal_data(i).', var_of_interest));
                

            end

                hold on
                plot(this_animal_data_plot(:, 2), '--', "Color", [0.9569 0.5 0.5])


            plot_data_cell_fem{1, a} = this_animal_data_plot(:, 2);
            plot_data_sizes_fem(1, a) = size(this_animal_data_plot(:, 2), 1);
            plot_data_labels_fem{:, a} = animalIDs_full_fem{a, :};

        clear this_animal_ind
        clear this_animal_data
        clear this_animal_target_learning_ind
        clear this_animal_data_plot

    end

max_plot_data_sizes_mal = max(plot_data_sizes_mal);

    for a = 1:size(plot_data_cell_mal, 2)

        if plot_data_sizes_mal(1, a) < max_plot_data_sizes_mal
            plot_data_mal(1:max_plot_data_sizes_mal, a) = NaN;
            plot_data_mal(1:plot_data_sizes_mal(1, a), a) = plot_data_cell_mal{1, a};
        else
            plot_data_mal(:, a) = plot_data_cell_mal{1, a};
        end

    end

max_plot_data_sizes_fem = max(plot_data_sizes_fem);

    for a = 1:size(plot_data_cell_fem, 2)

        if plot_data_sizes_fem(1, a) < max_plot_data_sizes_fem
            plot_data_fem(1:max_plot_data_sizes_fem, a) = NaN;
            plot_data_fem(1:plot_data_sizes_fem(1, a), a) = plot_data_cell_fem{1, a};
        else
            plot_data_fem(:, a) = plot_data_cell_fem{1, a};
        end

    end

end