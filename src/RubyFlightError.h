class RubyFlightError {
	public:
		RubyFlightError(unsigned long code);
		unsigned long getCode(void);

	private:
		unsigned long code;
};
