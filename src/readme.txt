TFieldUpdate v1.1
by Nathanial Woolls
natew@mobiletoys.com

This component is complete freeware.  Use it anywhere you want, for any
price.  Charge $1,000,000 for a commercial product that uses TFieldUpdate,
and do so without feeling dirty.  If you like the component, have any
suggestions, wish to donate any code, etc, email natew@mobiletoys.com

TFieldUpdate allows you to update the fields of a Paradox or DBase database
at runtime to match a set a field definitions supplied either at runtime
or design time.  The TFieldUpdate component allows you to add new field
definitions to TFieldUpdate.FieldItems, and modify those field definitions by
setting values for TFieldUpdate.FieldItems.Items[I].Name, .FieldType, .Length,
and .Precision.  You can also populate TFieldUpdate.FieldItems using the
procedure ReadFromFile(), specifying the path to a database from which to read
the field definitions.  This procedure is available at design time using the
property TFieldUpdate.ReadFrom, which allows you to browse for a database.
You can then apply these field definitions to a database at runtime using the
ApplyToFile() procedure, specifying the path to a database to which you want
to apply the field definitions contained in TFieldUpdate.FieldItems.
TFieldUpdate.LoadFromStream(), .SaveToStream(), .LoadFromFile(), .SaveToFile(),
.LoadFromIni(), .SaveToIni(), .LoadFromWinSock(), and .SaveToWinSock() are
available for saving and loading the field definitions to and from various
sources.

TFieldUpdate has two events, OnProgress, which passes an integer percentage
representing the progress of applying field definitions to a database and the
current field name begin updated, and OnError, which passes fuFileNotFound,
fuApply, fuRead, fuLoad, or fuSave to indicate where the problem was encountered
If an error occurs while applying field definitions (i.e. fuApply is passed),
then you can read TFieldUpdate.CurrentField to find what field was being
updated when the error occurred.

QuickStatus, QuickLabel, and QuickProgress are ease-of-use properties.
QuickLabel can be set to any TLabel on your form, and QuickProgress can be set
to any TProgressBar on your form. Then, if QuickStatus is set to True,
QuickLabel's caption will be updated to reflect the name of the current field
being updated, and QuickProgress will be automatically updated with the progress
of the field update progress.

One Use of TFieldUpdate (or at least how I use it) follows:
You have a customer base with a database whose fields need to be regularly
updated to match new or altered fields in your master database.  With
TFieldUpdate, simply place the component on your database update application
form, click on the ReadFrom property, browse to and select your master database.
Then, all you need is one line of code, calling:

FieldUpdate1.ApplyToFile('\path\to\customers\database');

And TFieldUpdate will properly update the customer's database to match yours.

Enjoy!
