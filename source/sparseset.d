module sparseset;

/**
* a @nogc-compatible implementation of a sparse set, such as might be used for an object pool.
* Authors: Susan
* Date: 2022-02-14
* Licence: AGPL-3.0 or later
* Copyright: Susan, 2021
*/

struct SparseSet(T, size_t maxSize)
{
	private ID[maxSize] sparse;
	private AugmentedID!(T, ID)[maxSize] packed;
	private size_t length;

	private alias ID = size_t;

	///
	void add(in ID id) @safe @nogc nothrow pure
	{
		packed[length].id = id;
		sparse[id] = length;
		++length;
	}

	/// ditto
	void add(in ID id, in T rhs) @safe @nogc nothrow pure
	{
		add(id);
		packed[length - 1].component = rhs;
	}

	///
	void remove(in ID id) @safe @nogc nothrow pure
	{
		import std.algorithm.mutation;
		swap(packed[id], packed[length]);

		--length;
	}

	///
	bool exists(in ID id) @safe @nogc nothrow pure
	{
		return ((sparse[id] < length) && (packed[sparse[id]].id == id));
	}

	///
	auto byId() @safe @nogc nothrow pure
	{
		auto b = ById!(T, ID)(packed[], sparse[]);
		return b;
	}

	///
	ref T opIndex(in size_t index) @safe @nogc nothrow pure
	{
		return packed[index].component;
	}
}

private struct AugmentedID(T, IDType)
{
	IDType id;
	T component;
}

private struct ById(T, IDType)
{
	AugmentedID!(T, IDType)[] source;
	IDType[] ids;

	ref T opIndex(in size_t index)
	{
		return source[ids[index]].component;
	}
}

@safe @nogc nothrow unittest
{
	SparseSet!(int, 8) foo;
	assert(foo.length == 0);

	immutable id = 2;

	assert(foo.exists(id) == false);

	foo.add(id, 69);

	assert(foo.length == 1);
	assert(foo.exists(id));
	assert(foo.byId[id] == 69);
	assert(foo[0] == 69);

	foo.remove(id);

	assert(foo.exists(id) == false);
	assert(foo.length == 0);

	foo.add(id);
	assert(foo.length == 1);
	assert(foo.exists(id));
	assert(foo.byId[id] == 69);

	foo.byId[id] = 420;
	assert(foo.length == 1);
	assert(foo.exists(id));
	assert(foo.byId[id] == 420);
}
