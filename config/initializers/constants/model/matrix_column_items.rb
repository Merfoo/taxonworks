# Be sure to restart your server when you modify this file.
MATRIX_COLUMN_ITEM_TYPES = ObservationMatrixColumnItem.descendants.inject({}){|hsh,a| hsh.merge(a.name => a.human_name) }.freeze

