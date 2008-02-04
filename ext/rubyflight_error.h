class RubyFlightError {
	public:
		RubyFlightError(unsigned long code);
		unsigned long get_code(void);

	private:
		unsigned long code;
};
