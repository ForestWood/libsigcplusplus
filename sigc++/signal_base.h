// -*- c++ -*-
/*
 * Copyright 2002, The libsigc++ Development Team
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */

#ifndef _SIGC_SIGNAL_BASE_H_
#define _SIGC_SIGNAL_BASE_H_

#include <list>
#include <sigc++/type_traits.h>
#include <sigc++/trackable.h>
#include <sigc++/functors/slot.h>
#include <sigc++/functors/mem_fun.h>

namespace sigc {

namespace internal {

/** Implementation of the signal interface.
 * signal_impl manages a list of slots. When a slot becomes
 * invalid (because some referred object dies), notify() is executed.
 * notify() either calls sweep() directly or defers the execution of
 * sweep() when the signal is being emitted. sweep() removes all
 * invalid slot from the list.
 */
struct signal_impl
{
  typedef size_t size_type;
  typedef std::list<slot_base>::iterator       iterator_type;
  typedef std::list<slot_base>::const_iterator const_iterator_type;

  signal_impl();

  /// Increments the reference counter.
  inline void reference()
    { ++ref_count_; }

  /// Increments the reference and execution counter.
  inline void reference_exec()
    { ++ref_count_; ++exec_count_; }

  /** Decrements the reference counter.
   * The object is deleted when the reference counter reaches zero.
   */
  inline void unreference()
    { if (!(--ref_count_)) delete this; }

  /** Decrements the reference and execution counter.
   * Invokes sweep() if the execution counter reaches zero and the
   * removal of one or more slots has been deferred.
   */
  inline void unreference_exec()
    {
      if (!(--ref_count_)) delete this;
      else if (!(--exec_count_) && deferred_) sweep();
    }

  /** Returns whether the list of slots is empty.
   * @return @p true if the list of slots is empty.
   */
  inline bool empty() const
    { return slots_.empty(); }

  /// Empties the list of slots.
  void clear();

  /** Returns the number of slots in the list.
   * @return The number of slots in the list.
   */
  size_type size() const;

  /** Adds a slot at the bottom of the list of slots.
   * @param slot_ The slot to add to the list of slots.
   * @return An iterator pointing to the new slot in the list.
   */
  iterator_type connect(const slot_base& slot_);

  /** Adds a slot at the given position into the list of slots.
   * @param i An iterator indicating the position where @p slot_ should be inserted.
   * @param slot_ The slot to add to the list of slots.
   * @return An iterator pointing to the new slot in the list.
   */
  iterator_type insert(iterator_type i, const slot_base& slot_);

  /** Removes the slot at the given position from the list of slots.
   * @param i An iterator pointing to the slot to be removed.
   * @return An iterator pointing to the slot in the list after the one removed.
   */
  iterator_type erase(iterator_type i);

  /// Removes invalid slots from the list of slots.
  void sweep();

  /** Callback that is executed when some slot becomes invalid.
   * This callback is registered in every slot when inserted into
   * the list of slots. It is executed when a slot becomes invalid
   * because of some referred object being destroyed.
   * It either calls sweep() directly or defers the execution of
   * sweep() when the signal is being emitted.
   * @param d The signal object (@p this).
   */
  static void* notify(void* d);

  /** Reference counter.
   * The object is destroyed when @em ref_count_ reaches zero.
   */
  short ref_count_;

  /** Execution counter.
   * Indicates whether the signal is being emitted.
   */
  short exec_count_;

  /// Indicates whether the execution of sweep() is being deferred.
  bool deferred_;

  /// The list of slots.
  std::list<slot_base> slots_;
};

/// Exception safe sweeper for cleaning up invalid slots on the slot list.
struct signal_exec
{
  /// The parent sigc::signal_impl object.
  signal_impl* sig_;

  /** Increments the reference and execution counter of the parent sigc::signal_impl object.
   * @param sig The parent sigc::signal_impl object.
   */
  inline signal_exec(const signal_impl* sig)
    : sig_(const_cast<signal_impl*>(sig) )
    { sig_->reference_exec(); }

  /// Decrements the reference and execution counter of the parent sigc::signal_impl object.
  inline ~signal_exec()
    { sig_->unreference_exec(); }
};

} /* namespace internal */

/** Base class for the sigc::signal# templates.
 * signal_base integrates most of the interface of the derived sigc::signal#
 * templates. The implementation, however, resides in sigc::internal::signal_impl.
 * A sigc::internal::signal_impl object is dynamically allocated from signal_base
 * when first connecting a slot to the signal. This ensures that empty signals
 * don't waste memory.
 *
 * @ingroup signal
 */
struct signal_base : public trackable
{
  typedef size_t size_type;

  signal_base();

  signal_base(const signal_base& src);

  ~signal_base();

  signal_base& operator = (const signal_base& src);

  /** Returns whether the list of slots is empty.
   * @return @p true if the list of slots is empty.
   */
  inline bool empty() const
    { return (!impl_ || impl_->empty()); }

  /// Empties the list of slots.
  void clear();

  /** Returns the number of slots in the list.
   * @return The number of slots in the list.
   */
  size_type size() const;

protected:
  typedef internal::signal_impl::iterator_type iterator_type;

  /** Adds a slot at the bottom of the list of slots.
   * @param slot_ The slot to add to the list of slots.
   * @return An iterator pointing to the new slot in the list.
   */
  iterator_type connect(const slot_base& slot_);

  /** Adds a slot at the given position into the list of slots.
   * @param i An iterator indicating the position where @e slot_ should be inserted.
   * @param slot_ The slot to add to the list of slots.
   * @return An iterator pointing to the new slot in the list.
   */
  iterator_type insert(iterator_type i, const slot_base& slot_);

  /** Removes the slot at the given position from the list of slots.
   * @param i An iterator pointing to the slot to be removed.
   * @return An iterator pointing to the slot in the list after the one removed.
   */
  iterator_type erase(iterator_type i);

  /** Returns the signal_impl object encapsulating the list of slots.
   * @return The signal_impl object encapsulating the list of slots.
   */
  internal::signal_impl* impl() const;

  /// The signal_impl object encapsulating the slot list.
  mutable internal::signal_impl* impl_;
};

} //namespace sigc

#endif /* _SIGC_SIGNAL_BASE_H_ */