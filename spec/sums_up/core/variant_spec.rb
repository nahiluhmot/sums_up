# frozen_string_literal: true

RSpec.describe SumsUp::Core::Variant do
  let(:no_arg_variant_class) do
    described_class.build_variant_class(
      :no_arg_variant,
      %i[one_arg_variant two_arg_variant],
      [],
      no_arg_matcher_class
    )
  end
  let(:one_arg_variant_class) do
    described_class.build_variant_class(
      :one_arg_variant,
      %i[no_arg_variant two_arg_variant],
      %i[value],
      one_arg_matcher_class
    )
  end
  let(:two_arg_variant_class) do
    described_class.build_variant_class(
      :two_arg_variant,
      %i[no_arg_variant one_arg_variant],
      %i[first second],
      two_arg_matcher_class
    )
  end
  let(:no_arg_matcher_class) { double(:no_arg_matcher_class) }
  let(:one_arg_matcher_class) { double(:one_arg_matcher_class) }
  let(:two_arg_matcher_class) { double(:two_arg_matcher_class) }

  let(:no_arg_variant_instance) { no_arg_variant_class.new }
  let(:one_arg_variant_instance) { one_arg_variant_class.new("test") }
  let(:two_arg_variant_instance) { two_arg_variant_class.new("left", "right") }

  describe ".new" do
    it "creates a new instance when provided the correct number of arguments" do
      expect(no_arg_variant_instance)
        .to(be_a(no_arg_variant_class))

      expect(one_arg_variant_instance)
        .to(be_a(one_arg_variant_class))

      expect(two_arg_variant_instance)
        .to(be_a(two_arg_variant_class))
    end

    it "raises when provided the wrong number of arguments" do
      expect { no_arg_variant_class.new("one") }
        .to(
          raise_error(
            ArgumentError,
            "wrong number of arguments (given 1, expected 0)"
          )
        )

      expect { no_arg_variant_class.new("one", "two") }
        .to(
          raise_error(
            ArgumentError,
            "wrong number of arguments (given 2, expected 0)"
          )
        )

      expect { one_arg_variant_class.new }
        .to(
          raise_error(
            ArgumentError,
            "wrong number of arguments (given 0, expected 1)"
          )
        )

      expect { one_arg_variant_class.new("one", "two") }
        .to(
          raise_error(
            ArgumentError,
            "wrong number of arguments (given 2, expected 1)"
          )
        )

      expect { two_arg_variant_class.new }
        .to(
          raise_error(
            ArgumentError,
            "wrong number of arguments (given 0, expected 2)"
          )
        )

      expect { two_arg_variant_class.new("one") }
        .to(
          raise_error(
            ArgumentError,
            "wrong number of arguments (given 1, expected 2)"
          )
        )
    end
  end

  describe "generated getters" do
    it "fetches the values" do
      expect(one_arg_variant_instance.value)
        .to(eq("test"))

      expect(two_arg_variant_instance.first)
        .to(eq("left"))

      expect(two_arg_variant_instance.second)
        .to(eq("right"))
    end
  end

  describe "generated setters" do
    it "updates values" do
      expect { one_arg_variant_instance.value = 42 }
        .to(
          change { one_arg_variant_instance.value }
            .from("test")
            .to(42)
        )

      expect { two_arg_variant_instance.first = 42 }
        .to(
          change { two_arg_variant_instance.first }
            .from("left")
            .to(42)
        )

      expect { two_arg_variant_instance.second = 42 }
        .to(
          change { two_arg_variant_instance.second }
            .from("right")
            .to(42)
        )
    end
  end

  describe "generated predicates" do
    it "returns true for matching variants" do
      expect(no_arg_variant_instance)
        .to(be_no_arg_variant)

      expect(one_arg_variant_instance)
        .to(be_one_arg_variant)

      expect(two_arg_variant_instance)
        .to(be_two_arg_variant)
    end

    it "returns false for mismatched variants" do
      expect(no_arg_variant_instance)
        .to_not(be_one_arg_variant)

      expect(no_arg_variant_instance)
        .to_not(be_two_arg_variant)

      expect(one_arg_variant_instance)
        .to_not(be_no_arg_variant)

      expect(one_arg_variant_instance)
        .to_not(be_two_arg_variant)

      expect(two_arg_variant_instance)
        .to_not(be_no_arg_variant)

      expect(two_arg_variant_instance)
        .to_not(be_one_arg_variant)
    end
  end

  describe "#[]" do
    it "raises given an unknown string key" do
      expect { no_arg_variant_instance["anything"] }
        .to(
          raise_error(
            NameError,
            "No member 'anything' in variant no_arg_variant"
          )
        )

      expect { one_arg_variant_instance["val"] }
        .to(
          raise_error(
            NameError,
            "No member 'val' in variant one_arg_variant"
          )
        )

      expect { one_arg_variant_instance["third"] }
        .to(
          raise_error(
            NameError,
            "No member 'third' in variant one_arg_variant"
          )
        )
    end

    it "raises given an unknown symbol key" do
      expect { no_arg_variant_instance[:anything] }
        .to(
          raise_error(
            NameError,
            "No member 'anything' in variant no_arg_variant"
          )
        )

      expect { one_arg_variant_instance[:val] }
        .to(
          raise_error(
            NameError,
            "No member 'val' in variant one_arg_variant"
          )
        )

      expect { one_arg_variant_instance[:third] }
        .to(
          raise_error(
            NameError,
            "No member 'third' in variant one_arg_variant"
          )
        )
    end

    it "returns the value given a known string key" do
      expect(one_arg_variant_instance["value"])
        .to(eq("test"))

      expect(two_arg_variant_instance["first"])
        .to(eq("left"))

      expect(two_arg_variant_instance["second"])
        .to(eq("right"))
    end

    it "returns the value given a known symbol key" do
      expect(one_arg_variant_instance[:value])
        .to(eq("test"))

      expect(two_arg_variant_instance[:first])
        .to(eq("left"))

      expect(two_arg_variant_instance[:second])
        .to(eq("right"))
    end
  end

  describe "#[]=" do
    it "raises given an unknown string key" do
      expect { no_arg_variant_instance["anything"] = nil }
        .to(
          raise_error(
            NameError,
            "No member 'anything' in variant no_arg_variant"
          )
        )

      expect { one_arg_variant_instance["val"] = nil }
        .to(
          raise_error(
            NameError,
            "No member 'val' in variant one_arg_variant"
          )
        )

      expect { one_arg_variant_instance["third"] = nil }
        .to(
          raise_error(
            NameError,
            "No member 'third' in variant one_arg_variant"
          )
        )
    end

    it "raises given an unknown symbol key" do
      expect { no_arg_variant_instance[:anything] = nil }
        .to(
          raise_error(
            NameError,
            "No member 'anything' in variant no_arg_variant"
          )
        )

      expect { one_arg_variant_instance[:val] = nil }
        .to(
          raise_error(
            NameError,
            "No member 'val' in variant one_arg_variant"
          )
        )

      expect { one_arg_variant_instance[:third] = nil }
        .to(
          raise_error(
            NameError,
            "No member 'third' in variant one_arg_variant"
          )
        )
    end

    it "updates the value given a known string key" do
      expect { one_arg_variant_instance["value"] = 42 }
        .to(
          change { one_arg_variant_instance.value }
            .from("test")
            .to(42)
        )

      expect { two_arg_variant_instance["first"] = 42 }
        .to(
          change { two_arg_variant_instance.first }
            .from("left")
            .to(42)
        )

      expect { two_arg_variant_instance["second"] = 42 }
        .to(
          change { two_arg_variant_instance.second }
            .from("right")
            .to(42)
        )
    end

    it "returns the value given a known symbol key" do
      expect { one_arg_variant_instance[:value] = 42 }
        .to(
          change { one_arg_variant_instance.value }
            .from("test")
            .to(42)
        )

      expect { two_arg_variant_instance[:first] = 42 }
        .to(
          change { two_arg_variant_instance.first }
            .from("left")
            .to(42)
        )

      expect { two_arg_variant_instance[:second] = 42 }
        .to(
          change { two_arg_variant_instance.second }
            .from("right")
            .to(42)
        )
    end
  end

  describe "#match" do
    let(:no_arg_matcher_instance) { double(:no_arg_matcher_instance) }
    let(:one_arg_matcher_instance) { double(:one_arg_matcher_instance) }
    let(:two_arg_matcher_instance) { double(:two_arg_matcher_instance) }

    before do
      allow(no_arg_matcher_class)
        .to(receive(:new))
        .with(no_arg_variant_instance)
        .and_return(no_arg_matcher_instance)

      allow(one_arg_matcher_class)
        .to(receive(:new))
        .with(one_arg_variant_instance)
        .and_return(one_arg_matcher_instance)

      allow(two_arg_matcher_class)
        .to(receive(:new))
        .with(two_arg_variant_instance)
        .and_return(two_arg_matcher_instance)

      allow(no_arg_matcher_instance)
        .to(receive(:_fetch_result))
        .with(no_args)
        .and_return("no arg variant match result")

      allow(one_arg_matcher_instance)
        .to(receive(:_fetch_result))
        .with(no_args)
        .and_return("one arg variant match result")

      allow(two_arg_matcher_instance)
        .to(receive(:_fetch_result))
        .with(no_args)
        .and_return("two arg variant match result")
    end

    context "given a block" do
      it "creates a matcher, yields it, then fetches the result" do
        no_arg_result = no_arg_variant_instance.match do |matcher|
          expect(matcher)
            .to(eq(no_arg_matcher_instance))
        end

        one_arg_result = one_arg_variant_instance.match do |matcher|
          expect(matcher)
            .to(eq(one_arg_matcher_instance))
        end

        two_arg_result = two_arg_variant_instance.match do |matcher|
          expect(matcher)
            .to(eq(two_arg_matcher_instance))
        end

        expect(no_arg_result)
          .to(eq("no arg variant match result"))

        expect(one_arg_result)
          .to(eq("one arg variant match result"))

        expect(two_arg_result)
          .to(eq("two arg variant match result"))
      end
    end

    context "given no block" do
      it "creates a matcher, matches the kwargs, and fetches the result" do
        expect(no_arg_matcher_instance)
          .to(receive(:_match_hash))
          .with({})

        expect(one_arg_matcher_instance)
          .to(receive(:_match_hash))
          .with(hash_including(one_arg: true))

        expect(two_arg_matcher_instance)
          .to(receive(:_match_hash))
          .with(hash_including(left: 1, right: 2))

        expect(no_arg_variant_instance.match(**{}))
          .to(eq("no arg variant match result"))

        expect(one_arg_variant_instance.match(one_arg: true))
          .to(eq("one arg variant match result"))

        expect(two_arg_variant_instance.match(left: 1, right: 2))
          .to(eq("two arg variant match result"))
      end
    end
  end

  describe "#members" do
    it "returns the an Array of the attributes" do
      expect(no_arg_variant_instance.members)
        .to(eq([]))

      expect(one_arg_variant_instance.members)
        .to(eq(%w[test]))

      expect(two_arg_variant_instance.members)
        .to(eq(%w[left right]))
    end
  end

  describe "#attributes" do
    it "returns the a Hash of the attributes" do
      expect(no_arg_variant_instance.attributes)
        .to(eq({}))

      expect(one_arg_variant_instance.attributes)
        .to(eq(value: "test"))

      expect(two_arg_variant_instance.attributes)
        .to(eq(first: "left", second: "right"))
    end
  end

  describe "#to_h" do
    it "returns the variant and a Hash of the attributes by default" do
      expect(no_arg_variant_instance.to_h)
        .to(eq(no_arg_variant: {}))

      expect(one_arg_variant_instance.to_h)
        .to(eq(one_arg_variant: {value: "test"}))

      expect(two_arg_variant_instance.to_h)
        .to(eq(two_arg_variant: {first: "left", second: "right"}))
    end

    it "returns the a Hash of the attributes with include_root: false" do
      expect(no_arg_variant_instance.to_h(include_root: false))
        .to(eq({}))

      expect(one_arg_variant_instance.to_h(include_root: false))
        .to(eq(value: "test"))

      expect(two_arg_variant_instance.to_h(include_root: false))
        .to(eq(first: "left", second: "right"))
    end
  end

  describe "#to_s" do
    it "returns a String representation of the variant" do
      expect(no_arg_variant_instance.to_s)
        .to(eq("#<variant no_arg_variant>"))

      expect(one_arg_variant_instance.to_s)
        .to(eq('#<variant one_arg_variant value="test">'))

      expect(two_arg_variant_instance.to_s)
        .to(eq('#<variant two_arg_variant first="left", second="right">'))
    end
  end

  describe "#==" do
    it "returns false when the values are not equal" do
      expect(no_arg_variant_instance)
        .to_not(eq(one_arg_variant_instance))

      expect(no_arg_variant_instance)
        .to_not(eq(two_arg_variant_instance))

      expect(one_arg_variant_instance)
        .to_not(eq(no_arg_variant_instance))

      expect(one_arg_variant_instance)
        .to_not(eq(two_arg_variant_instance))

      expect(two_arg_variant_instance)
        .to_not(eq(no_arg_variant_instance))

      expect(two_arg_variant_instance)
        .to_not(eq(one_arg_variant_instance))

      expect(one_arg_variant_instance)
        .to_not(
          eq(one_arg_variant_class.new(one_arg_variant_instance.value * 2))
        )

      expect(two_arg_variant_instance)
        .to_not(
          eq(
            two_arg_variant_class.new(
              two_arg_variant_instance.second,
              two_arg_variant_instance.first
            )
          )
        )
    end

    it "returns true given the same object" do
      expect(no_arg_variant_instance)
        .to(eq(no_arg_variant_instance))

      expect(one_arg_variant_instance)
        .to(eq(one_arg_variant_instance))

      expect(two_arg_variant_instance)
        .to(eq(two_arg_variant_instance))
    end

    it "returns true when the values are equal" do
      expect(no_arg_variant_instance)
        .to(eq(no_arg_variant_class.new))

      expect(one_arg_variant_instance)
        .to(eq(one_arg_variant_class.new(one_arg_variant_instance.value)))

      expect(two_arg_variant_instance)
        .to(
          eq(
            two_arg_variant_class.new(
              two_arg_variant_instance.first,
              two_arg_variant_instance.second
            )
          )
        )
    end
  end
end
