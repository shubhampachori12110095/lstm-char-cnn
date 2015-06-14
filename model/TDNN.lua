--[[
 Time-delayed CNN (i.e. 1-d CNN) with multiple filter widths
--]]
local TDNN = {}

function TDNN.tdnn(length, input_size, output_size, kernels)
  -- length = length of sentences/words (zero padded to be of same length)
  -- input_size = embedding_size
  -- output_size = number of output feature maps (per kernel)
  -- kernels = table of kernel widths
  local input = nn.Identity()() --input is batch_size x length x input_size
  local layer1 = {}
  for i = 1, #kernels do
      local reduced_l = length - kernels[i] + 1 
      local conv_layer = nn.TemporalConvolution(input_size, output_size, kernels[i])(input)
      local pool_layer = nn.TemporalMaxPooling(reduced_l)(nn.ReLU()(conv_layer))
      table.insert(layer1, pool_layer)
  end
  local layer1_concat = nn.JoinTable(3)(layer1)
  local output = nn.Squeeze()(layer1_concat)
  return nn.gModule({input}, {output})
end

return TDNN