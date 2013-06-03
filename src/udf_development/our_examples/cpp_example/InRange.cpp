#include "Vertica.h"
#include <sstream>

using namespace Vertica;
using namespace std;


class InRange : public TransformFunction
{
    virtual void processPartition(ServerInterface &srvInterface, 
                                  PartitionReader &inputReader, 
                                  PartitionWriter &outputWriter)
    {
        try {
            if (inputReader.getNumCols() != 3)
                vt_report_error(0, "Function only accepts 3 arguments, but %zu provided", inputReader.getNumCols());

            do {
                const vfloat value = inputReader.getFloatRef(0);
		const vfloat lower_bound = inputReader.getFloatRef(1);
		const vfloat upper_bound = inputReader.getFloatRef(2);

                if ( value >= lower_bound && value <= upper_bound )
                {
			outputWriter.setFloat(0, value);
			outputWriter.next();
                }
            } while (inputReader.next());
        } catch(exception& e) {
            // Standard exception. Quit.
            vt_report_error(0, "Exception while processing partition: [%s]", e.what());
        }
    }
};

class InRangeFactory : public TransformFunctionFactory
{
    // Tell Vertica that we take in a row with 1 string, and return a row with 1 string
    virtual void getPrototype(ServerInterface &srvInterface, ColumnTypes &argTypes, ColumnTypes &returnType)
    {
        argTypes.addFloat();
	argTypes.addFloat();
	argTypes.addFloat();

        returnType.addFloat();
    }

    virtual void getReturnType(ServerInterface &srvInterface, 
                               const SizedColumnTypes &inputTypes, 
                               SizedColumnTypes &outputTypes)
    {
        if (inputTypes.getColumnCount() != 3)
            vt_report_error(0, "Function only accepts 3 arguments, but %zu provided", inputTypes.getColumnCount());

        outputTypes.addFloat("value");
    }

    virtual TransformFunction *createTransformFunction(ServerInterface &srvInterface)
    { return vt_createFuncObj(srvInterface.allocator, InRange); }

};

RegisterFactory(InRangeFactory);
