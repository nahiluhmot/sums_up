# frozen_string_literal: true

RSpec.describe SumsUp::Maybe do
  describe ".of" do
    it "returns nothing given nil" do
      expect(SumsUp::Maybe.of(nil))
        .to(eq(SumsUp::Maybe.nothing))
    end

    it "wraps the value in a just given a non-nil value" do
      expect(SumsUp::Maybe.of(1))
        .to(eq(SumsUp::Maybe.just(1)))
    end
  end

  describe "#to_s" do
    it "uses the class name" do
      expect(SumsUp::Maybe.nothing.to_s)
        .to(eq("#<variant SumsUp::Maybe::Nothing>"))

      expect(SumsUp::Maybe.just(1).to_s)
        .to(eq("#<variant SumsUp::Maybe::Just value=1>"))
    end
  end

  describe "#chain" do
    it "returns nothing when the receiver is nothing" do
      expect(SumsUp::Maybe.nothing.chain(&:anything))
        .to(eq(SumsUp::Maybe.nothing))
    end

    it "yields the value and returns the result when the receiver is just" do
      expect(SumsUp::Maybe.just(1).chain { |x| SumsUp::Maybe.just(x * 2) })
        .to(eq(SumsUp::Maybe.just(2)))
    end
  end

  describe "#map" do
    it "returns nothing when the receiver is nothing" do
      expect(SumsUp::Maybe.nothing.map(&:succ))
        .to(eq(SumsUp::Maybe.nothing))
    end

    it "applies the function when the receiver is just" do
      expect(SumsUp::Maybe.just(1).map(&:succ))
        .to(eq(SumsUp::Maybe.just(2)))
    end
  end

  describe "#or_else" do
    it "yields when the receiver is nothing given a block" do
      expect(SumsUp::Maybe.nothing.or_else { 100 })
        .to(eq(100))
    end

    it "returns the default when the receiver is nothing given no block" do
      expect(SumsUp::Maybe.nothing.or_else(10))
        .to(eq(10))
    end

    it "returns the value when the receiver is just" do
      expect(SumsUp::Maybe.just(1).or_else(2))
        .to(eq(1))
    end
  end
end
