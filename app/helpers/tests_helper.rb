module TestsHelper

    def design_options
        TestPart::DESIGN_TYPES.map{ |key, val| [t(key), val] }
    end

    def data_type_options
        TestVariable::DATA_TYPES.map{ |key, val| [t(key), val] }
    end
end
