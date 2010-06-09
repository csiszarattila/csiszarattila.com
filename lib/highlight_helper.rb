module Nanoc3::Helpers::Filtering

  def highlight(syntax, &block)
    data = capture(&block)
    
    filtered_data = "\n"+Albino.colorize(data, syntax )+"\n" rescue data 
    # Append filtered data to buffer
    buffer = eval('_erbout', block.binding)
    buffer << filtered_data
  end

end