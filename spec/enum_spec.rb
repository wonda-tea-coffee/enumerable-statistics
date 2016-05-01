require 'spec_helper'
require 'enumerable/statistics'
require 'delegate'

RSpec.describe Enumerable do
  describe '#sum' do
    def self.with_enum(given_enum, description=given_enum.inspect, &example_group_block)
      if given_enum.is_a? Array
        given_enum = given_enum.each
        description += '.each'
      end

      describe "for #{description}" do
        let(:enum) { given_enum }
        let(:init) { 0 }
        let(:block) { nil }
        subject(:sum) { enum.sum(init, &block) }

        module_eval(&example_group_block)
      end
    end

    def self.with_init(init_value, &example_group_block)
      context "with init=#{init_value.inspect}" do
        let(:init) { init_value }

        module_eval(&example_group_block)
      end
    end

    def self.with_conversion(conversion_block, description, &example_group_block)
      context "with conversion `#{description}`" do
        let(:block) { conversion_block }

        module_eval(&example_group_block)
      end
    end

    def self.it_equals_with_type(x, type)
      it { is_expected.to be_an(type) }
      it { is_expected.to eq(x) }
    end

    def self.it_is_int_equal(n)
      it_equals_with_type(n, Integer)
    end

    def self.it_is_rational_equal(n)
      it_equals_with_type(n, Rational)
    end

    def self.it_is_float_equal(n)
      it_equals_with_type(n, Float)
    end

    def self.it_is_complex_equal(n)
      it_equals_with_type(n, Complex)
    end

    with_enum [] do
      it_is_int_equal(0)

      with_init(0.0) do
        it_is_float_equal(0.0)
      end
    end

    with_enum [3] do
      it_is_int_equal(3)

      with_init(0.0) do
        it_is_float_equal(3.0)
      end
    end

    with_enum [3, 5] do
      it_is_int_equal(8)
    end

    with_enum [3, 5, 7] do
      it_is_int_equal(15)
    end

    with_enum [3, Rational(5)] do
      it_is_rational_equal(Rational(8))
    end

    with_enum [3, 5, 7.0] do
      it_is_float_equal(15.0)
    end

    with_enum [3, Rational(5), 7.0] do
      it_is_float_equal(15.0)
    end

    with_enum [3, Rational(5), Complex(0, 1)] do
      it_is_complex_equal(Complex(Rational(8), 1))
    end

    with_enum [3, Rational(5), 7.0, Complex(0, 1)] do
      it_is_complex_equal(Complex(15.0, 1))
    end

    with_enum [3.5, 5] do
      it_is_float_equal(8.5)
    end

    with_enum [2, 8.5] do
      it_is_float_equal(10.5)
    end

    with_enum [Rational(1, 2), 1] do
      it_is_rational_equal(Rational(3, 2))
    end

    with_enum [Rational(1, 2), Rational(1, 3)] do
      it_is_rational_equal(Rational(5, 6))
    end

    with_enum [2.0, Complex(0, 3.0)] do
      it_is_complex_equal(Complex(2.0, 3.0))
    end

    with_enum [1, 2] do
      with_init(10)do
        it_is_int_equal(13)

        with_conversion ->(v) { v * 2 }, 'v * 2' do
          it_is_int_equal(16)
        end
      end
    end

    it 'calls a block for each item once' do
      yielded = []
      three = SimpleDelegator.new(3)
      ary = [1, 2.0, three]
      expect(ary.each.sum {|x| yielded << x; x * 2 }).to eq(12.0)
      expect(yielded).to eq(ary)
    end

    with_enum [Object.new] do
      specify do
        expect { subject }.to raise_error(TypeError)
      end
    end

    large_number = 100_000_000
    small_number = 1e-9
    until (large_number + small_number) == large_number
      small_number /= 10
    end

    with_enum [large_number, *[small_number]*10] do
      it_is_float_equal(large_number + small_number*10)
    end

    with_enum [Rational(large_number, 1), *[small_number]*10] do
      it_is_float_equal(large_number + small_number*10)
    end

    with_enum [small_number, Rational(large_number, 1), *[small_number]*10] do
      it_is_float_equal(large_number + small_number*11)
    end

    with_enum ["a", "b", "c"] do
      with_init("") do
        it { is_expected.to eq("abc") }
      end
    end

    with_enum [[1], [[2]], [3]] do
      with_init([]) do
        it { is_expected.to eq([1, [2], 3]) }
      end
    end
  end
end