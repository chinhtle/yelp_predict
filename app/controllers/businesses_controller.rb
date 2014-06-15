class BusinessesController < ApplicationController
    def index
        #https://developers.google.com/chart/interactive/docs/gallery/piechart?csw=1

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

        # Assigning more colors than the actual number of elements is OK,
        # but if there are more elements than colors then the scheme will be
        # off! Make sure there are enough pastel colors! We will assume
        # there will not be more elements, ever, than the actual number
        # of pastel colors.
        slice_pastel_colors = [{color: '#DEA5A4'}, {color: '#77DD77'},
                               {color: '#AEC6CF'}, {color: '#B39EB5'},
                               {color: '#CB99C9'}, {color: '#779ECB'},
                               {color: '#836953'}, {color: '#FF6961'},
                               {color: '#B39EB5'}, {color: '#FDFD96'}]

        opts   = { :height => 400,
                   # :title => 'My Daily Activities',
                   :pieHole => 0.5, :legend => {position: 'bottom', maxLines: 3},
                   :slices => slice_pastel_colors}

        @chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)

    end
end
