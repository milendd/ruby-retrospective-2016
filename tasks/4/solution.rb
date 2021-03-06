RSpec.describe 'Version' do
  describe '#initialize' do
    context 'when the component is greater than 10' do
      it 'succesfully creates an instance' do
        expect { Version.new('13.1.5') }.to_not raise_error
      end
    end
    
    context 'when the parameter is another Version' do
      it 'succesfully creates an instance' do
        a = Version.new('13.1.5')
        expect { Version.new(a) }.to_not raise_error
      end
    end
    
    context 'when there are no parameters' do
      it 'succesfully creates an instance' do
        expect { Version.new }.to_not raise_error
      end
    end
    
    context 'when there is empty parameter' do
      it 'succesfully creates an instance' do
        expect { Version.new('') }.to_not raise_error
      end
    end
    
    context 'when negative argument at the beginning of the version' do
      it 'raises argument error' do
        version = '-5.3.5'
        expect { Version.new(version) }
        .to raise_error(ArgumentError, "Invalid version string '#{version}'")
      end
    end
    
    context 'when negative argument inside the version' do
      it 'raises argument error' do
        version = '5.-3.5'
        expect { Version.new(version) }
        .to raise_error(ArgumentError, "Invalid version string '#{version}'")
      end
    end
    
    context 'when version begins with "."' do
      it 'raises argument error' do
        version = '.5'
        expect { Version.new(version) }
        .to raise_error(ArgumentError, "Invalid version string '#{version}'")
      end
    end
    
    context 'when version have multiple dots for delimiter' do
      it 'raises argument error' do
        version = '2..5'
        expect { Version.new(version) }
        .to raise_error(ArgumentError, "Invalid version string '#{version}'")
      end
    end
    
    context 'when version ends with "."' do
      it 'raises argument error' do
        version = '4.3.'
        expect { Version.new(version) }
        .to raise_error(ArgumentError, "Invalid version string '#{version}'")
      end
    end
  end
  
  describe '#<=>' do
    it "can compare with #<=>" do
      expect( Version.new('2.2.3.0.1') <=> Version.new('2.3.1') ).to eq -1
      expect( Version.new('2.3.1.0.0') <=> Version.new('2.3.1') ).to eq 0
      expect( Version.new('2.3.1.1.2') <=> Version.new('2.3.0') ).to eq 1
    end
  end
  
  describe '#==' do
    it "can compare with #==" do
      expect( Version.new('2.3.1') == Version.new('2.3.1.0') ).to eq true
      expect( Version.new('2.3.1') == Version.new('2.3.1.1.2') ).to eq false
    end
  end
  
  describe '#>' do
    it 'can compare with #>' do
      expect(Version.new('1.3.1') > Version.new('1.2.3.0.1')).to eq true
      expect(Version.new('1.3.1') > Version.new('1.3.1.1.2')).to eq false
    end
  end
  
  describe '#<' do
    it 'can compare with #<' do
      expect(Version.new('2.2.3.0.1') < Version.new('2.3.1')).to eq true
      expect(Version.new('2.3.1') < Version.new('2.3.1.0')).to eq false
    end
  end
  
  describe '#>=' do
    it 'can compare with #>=' do
      expect(Version.new('2.3.1') >= Version.new('2.3.1.0')).to eq true
      expect(Version.new('2.3.1') >= Version.new('2.3.1.1.2')).to eq false
    end
  end
  
  describe '#<=' do
    it 'can compare with #<=' do
      expect(Version.new('2.3.1') <= Version.new('2.3.1.0')).to eq true
      expect(Version.new('2.3.1.1.2') <= Version.new('2.3.1')).to eq false
    end
  end
  
  describe '#to_s' do
    context 'when zeros at the end of the version' do
      it 'removes them' do
        expect(Version.new('1.1.0.0').to_s).to eq '1.1'
      end
    end
    
    context 'when zeros at the beginning of the version' do
      it 'doesnt remove them' do
        expect(Version.new('0.2.1').to_s).to eq '0.2.1'
      end
    end
    
    context 'when zeros inside of the version' do
      it 'doesnt remove them' do
        expect(Version.new('5.0.3').to_s).to eq '5.0.3'
      end
    end
  end
  
  describe '#components' do
    context 'when all components and zero inside of the version' do
      it 'returns all' do
        expect(Version.new('1.0.5').components).to eq [1, 0, 5]
      end
    end
    
    context 'when all components and zero at the beginning of the version' do
      it 'returns all' do
        expect(Version.new('0.1.0.5').components).to eq [0, 1, 0, 5]
      end
    end
    
    context 'when all components and zero at the end of the version' do
      it 'removes all zeros at the end' do
        expect(Version.new('1.0.5.0.0').components).to eq [1, 0, 5]
      end
    end
    
    context 'when fixed number of components and more components' do
      it 'add zeros to the end' do
        a = Version.new('0.0.3')
        expect(a.components(5)).to eq [0, 0, 3, 0, 0]
        expect(a.to_s).to eq '0.0.3'
      end
    end
    
    context 'when fixed number of components and less components' do
      it 'removes the last components' do
        a = Version.new('1.3.3.5')
        expect(a.components(2)).to eq [1, 3]
        expect(a.to_s).to eq '1.3.3.5'
      end
    end
    
    context 'when fixed number of components and zeros in the middle' do
      it 'removes the last components correctly without removing the zero' do
        a = Version.new('1.3.0.0.1')
        expect(a.components(3)).to eq [1, 3, 0]
        expect(a.to_s).to eq '1.3.0.0.1'
      end
    end

    context 'when modifying the components' do
      it 'does not change its state' do
        a = Version.new("2.3.7.0")
        a.components << 4
        expect(a.components).to eq [2, 3, 7]
      end
    end
  end
  
  describe 'Range#to_a' do
    context 'when normal situation' do
      it 'returns all versions in range' do
        a = Version.new('1.3.0')
        b = Version.new('1.3.3')
        expected_array = ['1.3', '1.3.1', '1.3.2']
        expect(Version::Range.new(a, b).to_a).to eq expected_array
      end
    end
    
    context 'when overflow some parameter of the version' do
      it 'returns all versions in range' do
        result = Version::Range.new('1.2.8', '1.3.3').to_a
        expected_array = ['1.2.8', '1.2.9', '1.3', '1.3.1', '1.3.2']
        expect(result).to eq expected_array
      end
    end
    
    context 'when first version is bigger than the second' do
      it 'returns empty array' do
        expect(Version::Range.new('1.3.3', '1.2.9').to_a).to eq []
      end
    end
    
    context 'when not equal number of components' do
      it 'returns all versions in range' do
        result = Version::Range.new('2.1.9', '2.3').to_a
        expected_array = [
          '2.1.9',
          '2.2',
          '2.2.1',
          '2.2.2',
          '2.2.3',
          '2.2.4',
          '2.2.5',
          '2.2.6',
          '2.2.7',
          '2.2.8',
          '2.2.9'
        ]
        expect(result).to eq expected_array
      end
    end
  end
  
  describe 'Range#include?' do
    context 'when between the first and the second' do
      it 'returns true' do
        a = Version.new('1')
        b = Version.new('2')
        range = Version::Range.new(a, b)
        expect(range).to include Version.new('1.0.5')
      end
    end
    
    context 'when between the first and the second and component >= 10' do
      it 'returns true' do
        range = Version::Range.new('0.4.4', '0.5.7')
        expect(range).to include '0.4.9.9.9.9.9.9.9.9'
      end
    end

    context 'when it is smaller than range' do
      it 'returns false' do
        range = Version::Range.new('0.4.4', '0.5.7')
        expect(range).to_not include '0.4.3.9'
      end
    end
    
    context 'when it is bigger than range' do
      it 'returns false' do
        range = Version::Range.new('0.4.4', '0.5.7')
        expect(range).to_not include '0.5.7.1'
      end
    end
  end
end
