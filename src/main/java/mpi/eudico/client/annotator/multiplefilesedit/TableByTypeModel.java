package mpi.eudico.client.annotator.multiplefilesedit;

import javax.swing.table.AbstractTableModel;

import mpi.eudico.client.annotator.ElanLocale;
import mpi.eudico.server.corpora.clomimpl.type.Constraint;

/**
 * A model for the tier type table.
 */
public class TableByTypeModel extends AbstractTableModel {
	private static final long serialVersionUID = 4578323811309813869L;
	private MFEModel model;
	int new_row_counter = 0;
	
	/**
	 * Constructor.
	 * 
	 * @param model the base data model
	 */
	public TableByTypeModel(MFEModel model) {
		super();
		this.model = model;
	}

	/**
	 * Removes a number of rows from the table.
	 * 
	 * @param selectedRows an array of row indices
	 */
	public void removeRows(int[] selectedRows) {
		if(getColumnCount()>0) {
			for(int i=selectedRows.length-1;i>=0;i--) {
				model.removeTypeRow(selectedRows[i]);
				fireTableRowsDeleted(selectedRows[i], selectedRows[i]);
			}
		}
	}

	@Override
	public int getColumnCount() {
		return model.getTypeColumnCount();
	}

	@Override
	public int getRowCount() {
		return model.getTypeRowCount();
	}

	@Override
	public String getColumnName(int col) {
		return model.getTypeColumnName(col);
	}

	@Override
	public Object getValueAt(int row, int col) {
		return model.getTypeValueAt(row, col);
	}

	@Override
	public Class<? extends Object> getColumnClass(int col) {
		return getValueAt(0, col).getClass();
	}

	/**
	 * Returns {@code true} for the name column.
	 */
	@Override
	public boolean isCellEditable(int row, int col) {
		if(col==MFEModel.TYPE_NAMECOLUMN && model.isConsistentType(row)) {
			return true;
		}
		return false;
	}

	@Override
	public void setValueAt(Object value, int row, int col) {
		model.changeTypeValueAt(value, row, col);
		fireTableCellUpdated(row, col);
	}
	
	/**
	 * Adds a row for a new tier type.
	 * 
	 * @param constraint the stereotype constraint for the type 
	 */
	public void newRow(Constraint constraint) {
		int row = model.addType(ElanLocale.getString("MFE.Tables.NewLine")+(new_row_counter++), "", true,constraint);
		fireTableRowsInserted(row, row);
	}
}
