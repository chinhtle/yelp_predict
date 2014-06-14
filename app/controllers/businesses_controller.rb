class BusinessesController < ApplicationController
    def index

        data_table = GoogleVisualr::DataTable.new
        data_table.new_column('string', 'Personality')
        data_table.new_column('number', 'Matches')
        data_table.add_rows(5)
        data_table.set_cell(0, 0, 'Type 1'     )
        data_table.set_cell(0, 1, 11 )
        data_table.set_cell(1, 0, 'Type 2'      )
        data_table.set_cell(1, 1, 2  )
        data_table.set_cell(2, 0, 'Type 3'  )
        data_table.set_cell(2, 1, 2  )
        data_table.set_cell(3, 0, 'Type 4' )
        data_table.set_cell(3, 1, 2  )
        data_table.set_cell(4, 0, 'Type 5'    )
        data_table.set_cell(4, 1, 7  )

        opts   = { :width => 800, :height => 480,
                   # :title => 'My Daily Activities',
                   :pieHole => 0.5}

        @chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)

    end
end
