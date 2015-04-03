#include <iostream>
#include <cstdlib>
#include <string>
#include <cstring>
#include <map>
#include <list>

class Visitor;

class Exp
{
protected:
	Exp() {};
	Exp(const Exp& rhs) {};
	Exp& operator=(const Exp& rhs) {};
public:
	virtual int accept(Visitor& v) const = 0;
};

class Bin : public Exp
{
public:
	Bin(char oper, Exp* lhs, Exp* rhs)
	: Exp(), oper_(oper), lhs_(lhs), rhs_(rhs)
	{}
	virtual int accept(Visitor& v) const;
	char oper_; Exp* lhs_; Exp* rhs_;
private:
};

class Num : public Exp
{
public:
	Num(int val)
	: Exp(), val_(val)
	{}
	virtual int accept(Visitor& v) const;
	int val_;
private:
};

class Visitor
{
public:
	virtual int visitBin(const Bin& exp) = 0;
	virtual int visitNum(const Num& exp) = 0;
};

class PrettyPrinter : public Visitor
{
public:
	PrettyPrinter(std::ostream& ostr)
		: ostr_(ostr) {}
	virtual int visitBin(const Bin& e) {
		ostr_ << '('; e.lhs_->accept(*this);
		ostr_ << e.oper_; e.rhs_->accept(*this); ostr_ << ')';
		return 0;
	}
	virtual int visitNum(const Num& e) {
		ostr_ << e.val_;
		return 0;
	}
private:
	std::ostream& ostr_;
};

class Evaluator : public Visitor
{
public:
	Evaluator(std::ostream& ostr)
		: ostr_(ostr) {}
	virtual int visitBin(const Bin& e) {

		Num* num1 = new Num(e.lhs_->accept(*this));
		Num* num2 = new Num(e.rhs_->accept(*this));
		int a;
		if (e.oper_ == '+')
		{
			a = num1->val_ + num2->val_;
		}
		else if (e.oper_ == '-')
		{
			a = num1->val_ - num2->val_;
		}
		else if (e.oper_ == '*')
		{
			a = num1->val_ * num2->val_;
		}
		else if (e.oper_ == '/')
		{
			if (num2->val_ == 0)
			{
				a = 777;
			}
			else
			{
				a = num1->val_ / num2->val_;
			}
		}
		return a;
	}
	virtual int visitNum(const Num& e) {
		return e.val_;
	}
private:
	std::ostream& ostr_;
};


inline std::ostream& operator<<(std::ostream& o, const Exp& e)
{
	PrettyPrinter printer(o);
	e.accept(printer);
	Evaluator evaluator(o);
	int a = e.accept(evaluator);

	return o << " = " << a;
}

inline int Bin::accept(Visitor& v) const {
	return v.visitBin(*this);
}

inline int Num::accept(Visitor& v) const {
	return v.visitNum(*this);
}