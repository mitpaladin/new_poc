
# Get the fugly markup/HTML building for table data out of the specs.
class TableData
  def self.expected
    [
      %(<table><thead>\n<tr>\n<th>Tables</th>\n),
      %(<th style="text-align: center">Are</th>\n),
      %(<th style="text-align: right">Cool</th>\n),
      %(</tr>\n</thead><tbody>\n<tr>\n<td>col 3 is</td>\n),
      %(<td style="text-align: center">right-aligned</td>\n),
      %(<td style="text-align: right">$1600</td>\n),
      %(</tr>\n</tbody></table>\n)
    ].join
  end

  def self.markup
    [
      %(| Tables        | Are           | Cool  |\n),
      %(| ------------- |:-------------:| -----:|\n),
      %(| col 3 is      | right-aligned | $1600 |)
    ].join
  end
end
