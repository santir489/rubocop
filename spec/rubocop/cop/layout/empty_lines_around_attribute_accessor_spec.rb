# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundAttributeAccessor, :config do
  it 'registers an offense and corrects for code that immediately follows accessor' do
    expect_offense(<<~RUBY)
      attr_accessor :foo
      ^^^^^^^^^^^^^^^^^^ Add an empty line after attribute accessor.
      def do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      attr_accessor :foo

      def do_something
      end
    RUBY
  end

  it 'registers an offense and corrects for code that immediately follows accessor with comment' do
    expect_offense(<<~RUBY)
      attr_accessor :foo # comment
      ^^^^^^^^^^^^^^^^^^ Add an empty line after attribute accessor.
      def do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      attr_accessor :foo # comment

      def do_something
      end
    RUBY
  end

  it 'accepts code that separates a attribute accessor from the code with a newline' do
    expect_no_offenses(<<~RUBY)
      attr_accessor :foo

      def do_something
      end
    RUBY
  end

  it 'accepts code that where the attr_accessor is the last line' do
    expect_no_offenses('attr_accessor :foo')
  end

  it 'accepts code that separates attribute accessors from the code with a newline' do
    expect_no_offenses(<<~RUBY)
      attr_accessor :foo
      attr_reader :bar
      attr_writer :baz

      def do_something
      end
    RUBY
  end

  it 'accepts code when used in class definition' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_accessor :foo
      end
    RUBY
  end

  it 'accepts code when attribute method is method chained' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr.foo
      end
    RUBY
  end

  it 'does not register an offense and corrects when using `if` ... `else` branches' do
    expect_no_offenses(<<~RUBY)
      if condition
        attr_reader :foo
      else
        do_something
      end
    RUBY
  end

  context 'when `AllowAliasSyntax: true`' do
    let(:cop_config) { { 'AllowAliasSyntax' => true } }

    it 'does not register an offense for code that immediately `alias` syntax after accessor' do
      expect_no_offenses(<<~RUBY)
        attr_accessor :foo
        alias foo? foo

        def do_something
        end
      RUBY
    end
  end

  context 'when `AllowAliasSyntax: false`' do
    let(:cop_config) { { 'AllowAliasSyntax' => false } }

    it 'registers an offense for code that immediately `alias` syntax after accessor' do
      expect_offense(<<~RUBY)
        attr_accessor :foo
        ^^^^^^^^^^^^^^^^^^ Add an empty line after attribute accessor.
        alias foo? foo

        def do_something
        end
      RUBY
    end
  end

  context 'when `AllowedMethods: private`' do
    let(:cop_config) { { 'AllowedMethods' => ['private'] } }

    it 'does not register an offense for code that immediately ignored methods after accessor' do
      expect_no_offenses(<<~RUBY)
        attr_accessor :foo
        private :foo

        def do_something
        end
      RUBY
    end
  end

  context 'when `AllowedMethods: []`' do
    let(:cop_config) { { 'AllowedMethods' => [] } }

    it 'registers an offense for code that immediately ignored methods after accessor' do
      expect_offense(<<~RUBY)
        attr_accessor :foo
        ^^^^^^^^^^^^^^^^^^ Add an empty line after attribute accessor.
        private :foo

        def do_something
        end
      RUBY
    end
  end
end
